function filtered_structure = filterFields(binary_keep_vector, start_structure)
% for a given start_structure, return a subset of it's fields for which 

fields_in_structure	= fieldnames(start_structure);
fields_to_remove	= fields_in_structure( ~binary_keep_vector );
filtered_structure	= rmfield(start_structure, fields_to_remove);

end