locals {
  volumes_from = [for entry in var.volumes_from : {
    sourceContainer = entry.sourceContainer
    readOnly        = coalesce(entry.readOnly, false)
  }]

  mount_points = [for entry in var.mount_points : {
    containerPath = entry.containerPath
    sourceVolume  = entry.sourceVolume
    readOnly      = coalesce(entry.readOnly, false)
  }]

  health_check = {
    command     = var.health_check.command
    startPeriod = var.health_check.startPeriod
    interval    = coalesce(var.health_check.interval, 30)
    retries     = coalesce(var.health_check.retries, 3)
    timeout     = coalesce(var.health_check.timeout, 5)
  }
}
