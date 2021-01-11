CREATE TABLE [dbo].[DizionarioIstatAsl] (
    [CodiceRegione]      VARCHAR (3)   NOT NULL,
    [CodiceAsl]          VARCHAR (3)   NOT NULL,
    [DescrizioneAsl]     VARCHAR (128) NOT NULL,
    [DataUltimaModifica] DATETIME      NOT NULL,
    CONSTRAINT [PK_DizionarioIstatAsl] PRIMARY KEY CLUSTERED ([CodiceRegione] ASC, [CodiceAsl] ASC) WITH (FILLFACTOR = 95)
);

