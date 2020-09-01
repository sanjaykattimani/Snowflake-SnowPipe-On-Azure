-- SnowPipe - Azure  setup

CREATE  NOTIFICATION INTEGRATION BANKING_SNOWPIPE_EVENT
ENABLED =TRUE
TYPE=QUEUE
NOTIFICATION_PROVIDER=AZURE_STORAGE_QUEUE
AZURE_STORAGE_QUEUE_PRIMARY_URI='<Your_storage_queue_uri>'
AZURE_TENANT_ID='<Your_Tenant_ID>';

SHOW INTEGRATIONS;

desc NOTIFICATION INTEGRATION BANKING_SNOWPIPE_EVENT;




CREATE OR REPLACE STAGE BANK_TRANSACTIONS_STAGE
url = '<Your_storage_url>'
credentials = (azure_sas_token=
'<your-sas-token>'
);


show stages;

ls @BANK_TRANSACTIONS_STAGE;

//
//CREATE OR REPLACE pipe "BANK_TRANSACTIONS_PIPE"
//  auto_ingest = true
//  integration = 'BANKING_SNOWPIPE_EVENT'
//  as
//  copy into STAGE.BANK_TRANSACTIONS
//  from @BANK_TRANSACTIONS_STAGE
//  file_format = (type = 'CSV');
//


CREATE OR REPLACE pipe "BANK_TRANSACTIONS_PIPE"
  auto_ingest = true
  integration = 'BANKING_SNOWPIPE_EVENT'
  as
  copy into FINANCE.STAGE.BANK_TRANSACTIONS
(TransactionNo,DateTime,FromAccount,ToAccount,Amount,TypeOfTransaction,TranDescription,Source)
 from (SELECT $1,TO_DATE($2,'MM/DD/YYYY HH:MI AM'),$3,$4,$5,$6,$7,$8  FROM @BANK_TRANSACTIONS_STAGE )
  file_format = (type = 'CSV');



ALTER PIPE BANK_TRANSACTIONS_PIPE REFRESH;
