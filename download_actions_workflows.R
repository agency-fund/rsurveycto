urlBase = 'https://raw.githubusercontent.com/hugheylab/actions/main/workflows/'
workflowFiles = c(
  'check-deploy.yaml',
  'pkgdown.yaml',
  'test-coverage.yaml',
  'lint.yaml')
workflowDir = file.path('.github', 'workflows')
if (!dir.exists(workflowDir)) dir.create(workflowDir, recursive = TRUE)
for (workflowFile in workflowFiles) {
  download.file(paste0(urlBase, workflowFile), file.path(workflowDir, workflowFile))
}
