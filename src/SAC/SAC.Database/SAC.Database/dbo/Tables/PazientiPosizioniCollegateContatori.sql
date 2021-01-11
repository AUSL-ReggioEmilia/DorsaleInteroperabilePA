CREATE TABLE [dbo].[PazientiPosizioniCollegateContatori] (
    [Anno]      INT          NOT NULL,
    [Contatore] VARCHAR (16) NOT NULL,
    CONSTRAINT [PK_PazientiPosizioniCollegateContatori] PRIMARY KEY CLUSTERED ([Anno] ASC, [Contatore] ASC) WITH (FILLFACTOR = 70)
);

