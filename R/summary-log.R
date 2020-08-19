#' Create a tibble from `model_summaries()` data
#'
#' Runs [model_summaries()] on all models in the input and returns a subset of the each resulting summary as a tibble.
#'
#' @details
#' The following fields from `bbi_nonmem_summary` are extracted and included by default.
#' If you would like more fields from the summary object, you can extract them manually from the `bbi_summary` list column.
#'
#' * `error_msg` -- Error message from [model_summary()]. If `NULL` the call succeeded. If not `NULL`, the rest of the fields will be `NULL`.
#' * `needed_fail_flags` -- Logical for whether the call initially failed, but passed with the inclusion of `.fail_flags`
#' * `bbi_summary` -- The full `bbi_nonmem_summary` object for each row. This can be queried further by extracting it as a list, or by using `dplyr::mutate()` etc.
#' * `ofv` -- Objective function value from last estimation method, using `$ofv$ofv_no_constant` field.
#' * `param_count` -- Count of (non-fixed) parameters estimated in final estimation method.
#' * `estimation_method` -- Character vector of estimation method(s) used. Extracted from `$run_details`
#' * `problem_text` -- Character vector of text from `$PROB`. Extracted from `$run_details`
#' * `number_of_patients` -- Extracted from `$run_details`
#' * `number_of_obs` -- Extracted from `$run_details`
#' * `any_heuristics` -- Logical indicating whether _any_ of the columns extracted from `$run_heuristics` are `TRUE`. Duplicative information, but helpful for filtering.
#' * `covariance_step_aborted` -- Extracted from `$run_heuristics`
#' * `large_condition_number` -- Extracted from `$run_heuristics`
#' * `correlations_not_ok` -- Extracted from `$run_heuristics`
#' * `parameter_near_boundary` -- Extracted from `$run_heuristics`
#' * `hessian_reset` -- Extracted from `$run_heuristics`
#' * `has_final_zero_gradient` -- Extracted from `$run_heuristics`
#' * `minimization_terminated` -- Extracted from `$run_heuristics`
#'
#' @return
#' `summary_log()` will return a new tibble with the `'absolute_model_path'` column as the primary key,
#' and all the columns extracted from [model_summaries()] (but none of the other columns from the input tibble).
#'
#' `add_summary()` takes a `bbi_run_log_df` tibble (the output from [run_log()]) and returns the input tibble,
#' with all the columns extracted from [model_summaries()] joined onto it.
#'
#' @seealso [run_log()]
#' @inheritParams run_log
#' @param ... Arguments passed through to [model_summaries()].
#' @importFrom dplyr mutate
#' @importFrom purrr map transpose
#' @importFrom tibble as_tibble
#' @importFrom glue glue
#' @importFrom tidyr unnest_wider
#' @export
summary_log <- function(
  .base_dir = get_model_directory(),
  .recurse = TRUE,
  ...
) {

  # if no directory defined, set to working directory
  if (is.null(.base_dir)) {
    stop("`.base_dir` cannot be `NULL`. Either pass a valid directory path or use `set_model_directory()` to set `options('rbabylon.model_directory')` which will be used by default.", call. = FALSE)
  }

  mod_list <- find_models(.base_dir, .recurse)

  res_df <- summary_log_impl(mod_list, ...)

  return(res_df)
}


#' @rdname summary_log
#' @param .log_df a `bbi_run_log_df` tibble (the output of [run_log()])
#' @param ... Arguments passed through to [model_summaries()]
#' @export
add_summary <- function(
  .log_df,
  ...
) {
  df <- add_log_impl(.log_df, summary_log_impl, ...)
  return(df)
}


#' Build summary log
#'
#' Private implementation function for building the summary log from a list of model objects.
#' This is called by both [summary_log()] and [add_summary()].
#' @importFrom stringr str_subset
#' @importFrom fs dir_ls file_exists
#' @importFrom purrr map_df map_chr
#' @importFrom dplyr select everything mutate mutate_at vars
#' @importFrom jsonlite fromJSON
#' @importFrom tibble tibble
#' @param .mods List of model objects that will be passed to [model_summaries()].
#' @param ... Arguments passed through to [model_summaries()]
#' @keywords internal
summary_log_impl <- function(.mods, ...) {

  if(length(.mods) == 0) {
    return(tibble())
  }

  check_model_object_list(.mods)

  res_list <- model_summaries(.mods, ...)

  # create tibble from list of lists
  res_df <- res_list %>% transpose() %>% as_tibble() %>%
    mutate(
      !!ABS_MOD_PATH := unlist(.data[[ABS_MOD_PATH]]),
      !!SL_ERROR := unlist(.data[[SL_ERROR]]),
      !!SL_FAIL_FLAGS := unlist(.data[[SL_FAIL_FLAGS]])
    )

  # if ALL models failed, the next section will error trying to unnest them,
  # and everything else will be NULL/NA anyway, so we just return the errors here.
  if (all(!is.na(res_df[[SL_ERROR]]))) {
    warning(glue("ALL {nrow(res_df)} MODEL SUMMARIES FAILED in `summary_log()` call. Check `error_msg` column for details."))
    return(select(res_df, -.data[[SL_SUMMARY]], -.data[[SL_FAIL_FLAGS]]))
  }

  res_df <- mutate_at(
    res_df,
    vars(SL_SUMMARY),
    list(
      d = extract_details,
      ofv = extract_ofv,
      param_count = extract_param_count,
      h = extract_heuristics
    ))

  res_df <- res_df %>% unnest_wider(.data$d) %>% unnest_wider(.data$h)

  return(res_df)
}

###################
# helper functions
###################

#' Extract from summary object
#'
#' These are all helper functions to extract a specific field or sub-field from a `bbi_{.model_type}_summary` object.
#' @name extract_from_summary
#' @param .s The summary object to extract from
NULL

#' @describeIn extract_from_summary Extract count of non-fixed parameters
#' @importFrom purrr map map_int
extract_param_count <- function(.s) {

  .pm <- map(.s, "parameters_data")

  .out <- map_int(.pm, function(.x) {
    num_methods <- length(.x)

    .fix <- unlist(.x[[num_methods]]$fixed)
    length(.fix) - sum(.fix)
  })

  return(.out)
}

#' @describeIn extract_from_summary Extract `run_details` field
#' @importFrom purrr map
extract_details <- function(.s) {
  .rd <- map(.s, SUMMARY_DETAILS, .default = NA)

  KEEPERS <- c("estimation_method", "problem_text", "number_of_patients", "number_of_obs")

  .out <- map(.rd, function(.x) {
    if(!inherits(.x, "list")) {
      return(NULL)
    }
    return(.x[KEEPERS])
  })

  return(.out)
}

#' @describeIn extract_from_summary Extract `run_heuristics` field
#' @importFrom purrr map
extract_heuristics <- function(.s) {
  .rh <- map(.s, "run_heuristics", .default = NA)

  .out <- map(.rh, function(.x) {
    if(!inherits(.x, "list")) {
      return(NULL)
    }

    .x <- .x[HEURISTICS_ELEMENTS]

    .any <- list()
    .any[[ANY_HEURISTICS]] = any(unlist(.x))

    return(combine_list_objects(.any, .x))
  })

  return(.out)
}

#' @describeIn extract_from_summary Extract objective function value
#' @importFrom purrr map map_dbl
#' @param .subfield The field to extract from within "ofv". Defaults to the objective function value with no constant added, but the other fields are available too.
extract_ofv <- function(.s, .subfield = c("ofv_no_constant", "ofv_with_constant", "ofv")) {
  .subfield <- match.arg(.subfield)
  .ofv <- map(.s, "ofv")
  .out <- map_dbl(.ofv, .subfield, .default = NA_real_)
  return(.out)
}

