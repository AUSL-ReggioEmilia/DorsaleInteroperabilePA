CREATE TABLE [dbo].[FileContentType] (
    [Extension]   VARCHAR (10) NOT NULL,
    [ContentType] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_AllegatiContentType] PRIMARY KEY CLUSTERED ([Extension] ASC) WITH (FILLFACTOR = 95)
);

