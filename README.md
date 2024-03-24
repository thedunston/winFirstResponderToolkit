# winFirstResponderToolkit

Toolkit to collect data from a windows system. It is used if there is a suspected or known security incident.

The tools are from nirsoft.net - https://www.nirsoft.net/, Sysinternals - https://learn.microsoft.com/en-us/sysinternals/ (namely PSTools), https://learn.microsoft.com/en-us/sysinternals/, goBodyFile - https://github.com/thedunston/goBodyFile.

Download the tools needed from the websites above or from other websites. The tools in this toolkit all have a CLI based interface. Most nirsoft tools have a GUI and CLI option.

I didn't include those here so that you can create your own toolkit using the tools based on your unique environment. You can follow the format of this toolkit or create your own.

If you have a custom program and want to add to the results directory, then place the output of the resulting file in:

````
 %TKTNUM%-%COMPUTERNAME%-Results\
````

for example,

````
command.exe -s option1 -output  %TKTNUM%-%COMPUTERNAME%-Results\resultingFile.txt
````

Feel free to edit this toolkit to your needs or use it as a baseline to create your own.  All the functions were used to make the script more readable.
