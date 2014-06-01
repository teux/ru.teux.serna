@echo off
SET WD=%CD%
pushd %DITA_HOME%

IF defined SERNA_XML_SRCFILENAME (
	ant -f %WD%\build.xml teux.file -Dtopic.file=%SERNA_XML_SRCFILENAME%
) ELSE ant -f %WD%\build.xml teux.site -l %WD%\result.log


popd
