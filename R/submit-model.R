###############################################
# S3 dispatches for submitting a single model
###############################################

#' Submit a model to be run
#'
#' Submits a model to be run by calling out to `bbi`.
#' @seealso [submit_models()]
#' @param .mod The model object to submit.
#' @param .bbi_args A named list specifying arguments to pass to bbi
#'   formatted like `list("nm_version" = "nm74gf_nmfe", "json" = T, "threads" =
#'   4)`. Run [print_bbi_args()] to see valid arguments. Note that bbr does
#'   not support changing the output directory (including through the model or
#'   global YAML files).
#' @param .mode Either `"sge"`, the default, to submit model(s) to the grid or
#'   `"local"` for local execution.
#' @param ... args passed through to `bbi_exec()`
#' @param .config_path Path to a bbi configuration file. If `NULL`, the
#'   default, will attempt to use a `bbi.yaml` in the same directory as the
#'   model.
#' @param .wait If `TRUE`, the default, wait for the bbi process to return
#'   before this function call returns. If `FALSE` function will return while
#'   bbi process runs in the background.
#' @param .dry_run Returns an object detailing the command that would be run,
#'   insted of running it. This is primarily for testing but also a debugging
#'   tool.
#' @export
submit_model <- function(
  .mod,
  .bbi_args = NULL,
  .mode = c("sge", "local"),
  ...,
  .config_path = NULL,
  .wait = TRUE,
  .dry_run=FALSE
) {
  UseMethod("submit_model")
}

#' @describeIn submit_model Takes a `bbi_nonmem_model` object.
#' @export
submit_model.bbi_nonmem_model <- function(
  .mod,
  .bbi_args = NULL,
  .mode = c("sge", "local"),
  ...,
  .config_path = NULL,
  .wait = TRUE,
  .dry_run=FALSE
) {

  res <- submit_nonmem_model(.mod,
                             .bbi_args = .bbi_args,
                             .mode = .mode,
                             ...,
                             .config_path = .config_path,
                             .wait = .wait,
                             .dry_run = .dry_run)
  return(res)
}


#####################################
# Private implementation function(s)
#####################################

#' Submit a NONMEM model via bbi
#'
#' Private implementation function called by `submit_model()` dispatches.
#' @param .mod An S3 object of class `bbi_nonmem_model`, for example from `new_model()`, `read_model()` or `copy_model_from()`
#' @importFrom stringr str_detect
#' @importFrom tools file_path_sans_ext
#' @return An S3 object of class `bbi_process`
#' @keywords internal
submit_nonmem_model <- function(.mod,
                                .bbi_args = NULL,
                                .mode = c("sge", "local"),
                                ...,
                                .config_path = NULL,
                                .wait = TRUE,
                                .dry_run=FALSE) {

  # check against YAML
  check_yaml_in_sync(.mod)

  # check for valid type arg
  .mode <- match.arg(.mode)

  # build command line args
  .bbi_args <- parse_args_list(.bbi_args, .mod[[YAML_BBI_ARGS]])
  args_vec <- check_bbi_args(.bbi_args)
  cmd_args <- c("nonmem", "run", .mode, get_model_path(.mod), args_vec)

  # define working directory
  model_dir <- get_model_working_directory(.mod)

  if (!is.null(.config_path)) {
    checkmate::assert_file_exists(.config_path)
    cmd_args <- c(
      cmd_args,
      sprintf("--config=%s", normalizePath(.config_path))
    )
  }

  if (.dry_run) {
    # construct fake res object
    return(bbi_dry_run(cmd_args, model_dir))
  }

  # launch model
  res <- bbi_exec(cmd_args, .wait = .wait, .dir = model_dir, ...)

  return(res)
}
