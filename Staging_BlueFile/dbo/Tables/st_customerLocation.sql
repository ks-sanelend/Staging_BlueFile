CREATE TABLE [dbo].[st_customerLocation] (
    [customerLocationUuid] VARCHAR (100) NOT NULL,
    [tradeEntityUuid]      VARCHAR (100) NOT NULL,
    [locationUuid]         VARCHAR (100) NOT NULL,
    [description]          VARCHAR (100) NULL,
    [deliveryLocationUuid] VARCHAR (100) NOT NULL,
    [status]               VARCHAR (100) NULL,
    [type]                 VARCHAR (100) NULL,
    [loadDate]             DATETIME      NULL
);

