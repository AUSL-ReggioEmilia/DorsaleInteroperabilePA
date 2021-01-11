ECHO OFF
ECHO:--------------------------------------------
ECHO:PostBuild operation: CreaSchemi.bat
ECHO:--------------------------------------------
ECHO:Le chiamate in CreaSchemi.bat sono commentate poiche' al momento non ho a disposizione XSD.EXE
ECHO:--------------------------------------------

REM CD %2
REM del DwhConn.DataAccess.Esterno.xsd
REM del ConnectorV2.xsd
REM del MessaggioEvento.xsd
REM "C:\Program Files\Microsoft SDKs\Windows\v6.0A\Bin\xsd.exe" %1 /o:%2
REM ren schema0.xsd DwhConn.DataAccess.Esterno.xsd
REM "C:\Program Files\Microsoft SDKs\Windows\v6.0A\Bin\xsd.exe" %1 /o:%2 /t:DwhConn.DataAccess.Esterno.MessaggioEvento
REM ren schema0.xsd MessaggioEvento.xsd
REM "C:\Program Files\Microsoft SDKs\Windows\v6.0A\Bin\xsd.exe" %1 /o:%2 /t:DwhConn.DataAccess.Esterno.ConnectorV2
REM ren schema0.xsd ConnectorV2.xsd



