library('data.table')
library('qs')

snapshot = function(xObs, path) {
  if (file.exists(path)) {
    xExp = qread(path)
  } else {
    qsave(xObs, path)
    xExp = xObs}
  return(xExp)}

dataDir = 'data'
if (!dir.exists(dataDir)) dir.create(dataDir)
