function speak(string)

if ismac
	try
		command = sprintf('!say %s',string);
		eval(command)
	catch
		beep
	end
else
	beep
end

