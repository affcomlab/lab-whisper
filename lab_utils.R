# /lab_config/lab_utils.R

#' Connect to AffCom Research Servers
#' Interactively mounts lab drives with student credentials.
#' - Datasets: READ-ONLY (Safe)
#' - Projects: READ-WRITE (For saving results)
connect_lab_drives <- function(username = NULL) {
  
  # --- SERVER CONFIGURATION ---
  mounts <- list(
    # DATASETS: Read-Only (ro)
    list(
      remote = "//resfs.home.ku.edu/groups_hipaa/lsi/jgirard/general/datasets", 
      local = "/mnt/datasets",
      flags = "ro,vers=3.0,sec=ntlmssp" 
    ),
    # PROJECTS: Read-Write (rw) with full permissions (0777)
    list(
      remote = "//resfs.home.ku.edu/groups_hipaa/lsi/jgirard/general/projects", 
      local = "/mnt/projects",
      flags = "rw,vers=3.0,sec=ntlmssp,file_mode=0777,dir_mode=0777"
    )
  )
  # ----------------------------

  # 1. Check if already connected
  if (length(list.files(mounts[[1]]$local)) > 0) {
    message("✅ Lab drives appear to be already connected.")
    return(invisible(TRUE))
  }

  # 2. Get Credentials
  message("--- AffCom Lab Server Login ---")
  if (is.null(username)) username <- readline("Enter KU Username: ")
  if (!requireNamespace("getPass", quietly = TRUE)) stop("Package 'getPass' missing.")
  password <- getPass::getPass("Enter KU Password: ")

  # 3. Mount Loop
  success <- TRUE
  
  for (m in mounts) {
    # Construct command with specific flags for this mount
    cmd <- sprintf(
      "mount -t cifs '%s' '%s' -o username='%s',password='%s',%s",
      m$remote, m$local, username, password, m$flags
    )
    
    exit_code <- system(cmd, ignore.stderr = TRUE)
    
    if (exit_code == 0) {
      # Visual confirmation of permissions
      perm_label <- ifelse(grepl("ro,", m$flags), "(Read-Only)", "(Read-Write)")
      message(sprintf("✅ Mounted: %s %s", m$local, perm_label))
    } else {
      message(sprintf("❌ Failed to mount: %s", m$local))
      success <- FALSE
    }
  }

  if (success) {
    message("\n🚀 All drives connected successfully!")
  } else {
    warning("\n⚠️ Some drives failed to connect. Check your password or VPN.")
  }
}

message("Loaded AffCom Lab Utils. Run connect_lab_drives() to login.")
