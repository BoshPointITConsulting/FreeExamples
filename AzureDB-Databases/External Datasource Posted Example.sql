/*Create a simple External Data Source that uses a unique user to get the information
The example below uses three AzureDB's: Master, ReportRunner and Website which have already
been created and contains tables.
*/
--Step One: Switch to the Master Database
CREATE LOGIN WebsiteDBQueryUser WITH PASSWORD = 'EnterUniquePasswordHere' --Select or Create your specific Login and Password.

--Step Two: Switch to the Website Database.  
/* We create the user from the login created in Master.  We grant specific permissions per table in this step as well.
*/
CREATE USER WebsiteDBQueryUser FOR LOGIN WebsiteDBQueryUser
--Grant the permissions to database tables that will be accessible
GRANT SELECT, INSERT ON dbo.Accounts TO WebsiteDBQueryUser --(Website Database Table)
GRANT SELECT, INSERT ON dbo.Vendor TO WebsiteDBQueryUser --(Website Database Table)

--Step Three: Switch to the ReportRunner Database
/*
Next, we need a master key for security in the ReportRunner database. 
Let's go there and create a master key with a password if one has been created. Please use a strong password here.
*/
SELECT TOP 10 * FROM SYS.SYMMETRIC_KEYS -- Checks to see if there is a key
--If no rows are returned no key exists. 
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'EnterUniquePasswordHere';

-- Step Four: Create a database scoped credential
CREATE DATABASE SCOPED CREDENTIAL WebsiteDBQueryCredential  WITH IDENTITY = 'WebsiteDBQueryUser', SECRET = 'EnterUniquePasswordHere' 

--Step Five: Create the External Data Source.  
/*
Important things to remember.  The columns must be exactly as they are in the original dataset. You do not have to include them all, 
but you can not change the data types. So datatypes are not allowed to be external data source columns. External Data Sources are read only
and when called they pull the information each time they are called.  They do not store information so they are slow.
*/
CREATE EXTERNAL DATA SOURCE WebsiteExtTbl
 WITH 
 ( TYPE = RDBMS,
   LOCATION='azsqldb_bpic_llc_exmpl1_dev.database.windows.net',
   DATABASE_NAME = 'Website',
   CREDENTIAL = WebsiteDBQueryCredential
 );

 
CREATE TABLE [dbo].[Accounts](
	[AccountRegID] [uniqueidentifier] NOT NULL,
	[CustomerName] [varchar](65) NOT NULL,
	[Logo] [image] NULL,
	[Email] [varchar](255) NULL,
    [Address1] [varchar](255) NULL,
    [Address2] [varchar](255) NULL,
	[Address3] [varchar](255) NULL,
    [City_Town] [varchar](255) NULL,
    [State_Prov] [varchar](255) NULL,
    [Zip] [varchar](255) NULL,
    [Country] [varchar](255) NULL)
GO

CREATE TABLE [dbo].[Vendor](
	[Vdr_PrimaryId] [uniqueidentifier] NOT NULL,
	[Vdr_Name] [nvarchar](255) NOT NULL,
    [VdrAddress1] [varchar](255) NULL,
    [VdrAddress2] [varchar](255) NULL,
	[VdrAddress3] [varchar](255) NULL,
    [VdrCity_Town] [varchar](255) NULL,
    [VdrState_Prov] [varchar](255) NULL,
    [VdrZip] [varchar](255) NULL,
    [VdrCountry] [varchar](255) NULL,
	[Vdr_Description] [nvarchar](255) NULL,
	[Vdr_Cntct1_Name] [nvarchar](255) NULL,
	[Vdr_Cntct1_Mbl_Tel_Nmb] [nvarchar](255) NULL,
	[Vdr_Cntct1_EmailAddress] [nvarchar](255) NULL,
	[Vdr_Fax_Number] [nvarchar](255) NULL)
GO

--Simple Checks for information.
SELECT * FROM Accounts
SELECT * FROM Vendor
-- Simple Drop Commands if no longer needed.
DROP EXTERNAL TABLE  Accounts
DROP EXTERNAL TABLE Vendor