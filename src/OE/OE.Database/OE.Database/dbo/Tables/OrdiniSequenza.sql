CREATE TABLE [dbo].[OrdiniSequenza] (
    [Anno]   INT      NOT NULL,
    [Numero] INT      NOT NULL,
    [Data]   DATETIME NOT NULL,
    CONSTRAINT [PK_OrdiniSequenza] PRIMARY KEY CLUSTERED ([Anno] ASC, [Numero] ASC)
);

