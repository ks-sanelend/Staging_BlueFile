﻿CREATE TABLE [dbo].[st_priceSurveyFailedRecords] (
    [Domain]                    VARCHAR (8)     NULL,
    [taskInstanceUuid]          VARCHAR (100)   NULL,
    [pdFUuid]                   VARCHAR (100)   NULL,
    [keyprodCategory]           INT             NULL,
    [KeyCustomer]               INT             NULL,
    [appointmentTypeUuid]       VARCHAR (100)   NULL,
    [keyscheduleType]           INT             NULL,
    [keyappointmentDate]        INT             NULL,
    [keystartTime]              INT             NULL,
    [keyendTime]                INT             NULL,
    [companyUserUuid]           VARCHAR (100)   NULL,
    [customerLocationUuid]      VARCHAR (100)   NULL,
    [customerAccountUuid]       VARCHAR (100)   NULL,
    [tradeChannelUuid]          VARCHAR (100)   NULL,
    [principalUuid]             VARCHAR (100)   NULL,
    [serviceProviderUuid]       VARCHAR (100)   NULL,
    [salesAgencyCostCentreUuid] VARCHAR (100)   NULL,
    [keytaskStatus]             INT             NULL,
    [keycompletedDate]          INT             NULL,
    [keycompletedTime]          INT             NULL,
    [taskTypeUuid]              VARCHAR (100)   NULL,
    [currency]                  VARCHAR (13)    NULL,
    [unitPrice]                 DECIMAL (18, 2) NULL,
    [shrinkPrice]               DECIMAL (18, 2) NULL,
    [promo]                     VARCHAR (1)     NOT NULL,
    [acceptUnitPrice]           VARCHAR (1)     NULL,
    [acceptShrinkPrice]         VARCHAR (1)     NULL
);

