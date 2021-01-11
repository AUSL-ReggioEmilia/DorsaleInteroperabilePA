CREATE TABLE [dbo].[PazientiAnonimizzazioniContatori] (
    [Anno]      INT         NOT NULL,
    [Contatore] VARCHAR (8) NOT NULL,
    CONSTRAINT [PK_PazientiAnonimizzazioniContatori_1] PRIMARY KEY CLUSTERED ([Anno] ASC, [Contatore] ASC)
);

