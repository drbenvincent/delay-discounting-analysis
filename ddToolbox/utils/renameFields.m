function renamedStruct = renameFields(struct, oldFields, newFields)

assert(iscellstr(oldFields))
assert(iscellstr(newFields))
assert(numel(oldFields)==numel(newFields))

for n=1:numel(oldFields)
	renamedStruct.(newFields{n}) = struct.(oldFields{n});
end

end