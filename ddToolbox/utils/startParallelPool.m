function startParallelPool()
  if isempty(gcp('nocreate'))
    parpool
  end
end
