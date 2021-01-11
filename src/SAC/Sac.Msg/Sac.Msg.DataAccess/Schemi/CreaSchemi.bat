CD %2

del MessaggioPaziente.xsd
del RispostaPaziente.xsd
del RispostaUtentiAck.xsd
del MessaggioConsenso.xsd
del RispostaConsenso.xsd
del RispostaListaPazienti.xsd
del RispostaDettaglioPaziente.xsd

"C:\Program Files\Microsoft SDKs\Windows\v6.0A\Bin\xsd.exe" %1 /o:%2 /t:Asmn.Sac.Msg.DataAccess.MessaggioPaziente
ren schema0.xsd MessaggioPaziente.xsd

"C:\Program Files\Microsoft SDKs\Windows\v6.0A\Bin\xsd.exe" %1 /o:%2 /t:Asmn.Sac.Msg.DataAccess.RispostaPaziente
ren schema0.xsd RispostaPaziente.xsd

"C:\Program Files\Microsoft SDKs\Windows\v6.0A\Bin\xsd.exe" %1 /o:%2 /t:Asmn.Sac.Msg.DataAccess.RispostaUtentiAck
ren schema0.xsd RispostaUtentiAck.xsd

"C:\Program Files\Microsoft SDKs\Windows\v6.0A\Bin\xsd.exe" %1 /o:%2 /t:Asmn.Sac.Msg.DataAccess.MessaggioConsenso
ren schema0.xsd MessaggioConsenso.xsd

"C:\Program Files\Microsoft SDKs\Windows\v6.0A\Bin\xsd.exe" %1 /o:%2 /t:Asmn.Sac.Msg.DataAccess.RispostaConsenso
ren schema0.xsd RispostaConsenso.xsd

"C:\Program Files\Microsoft SDKs\Windows\v6.0A\Bin\xsd.exe" %1 /o:%2 /t:Asmn.Sac.Msg.DataAccess.RispostaListaPazienti
ren schema0.xsd RispostaListaPazienti.xsd

"C:\Program Files\Microsoft SDKs\Windows\v6.0A\Bin\xsd.exe" %1 /o:%2 /t:Asmn.Sac.Msg.DataAccess.RispostaDettaglioPaziente
ren schema0.xsd RispostaDettaglioPaziente.xsd
