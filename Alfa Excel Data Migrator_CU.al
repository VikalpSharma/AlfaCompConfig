codeunit 70140953 "Alfa Excel Data Migrator"
{
    // version NAVW113.00


    trigger OnRun()
    begin
    end;

    var
        PackageCodeTxt: Label 'UAE.ENU.EXCEL';
        PackageNameTxt: Label 'Excel Data Migration';
        ConfigPackageManagement: Codeunit "Config. Package Management";
        ConfigExcelExchange: Codeunit "Config. Excel Exchange";
        DataMigratorDescriptionTxt: Label 'Import from Excel';
        Instruction1Txt: Label '1) Download the Excel template.';
        Instruction2Txt: Label '2) Fill in the template with your data.';
        Instruction3Txt: Label '3) Optional, but important: Specify import settings. These help ensure that you can use your data right away.';
        Instruction4Txt: Label '4) Choose Next to upload your data file.';
        ImportingMsg: Label 'Importing Data...';
        ApplyingMsg: Label 'Applying Data...';
        ImportFromExcelTxt: Label 'Import from Excel';
        ExcelFileExtensionTok: Label '*.xlsx';
        ExcelValidationErr: Label 'The file that you imported is corrupted. It contains columns that cannot be mapped to %1.', Comment = '%1 - product name';
        OpenAdvancedQst: Label 'The advanced setup experience requires you to specify how database tables are configured. We recommend that you only access the advanced setup if you are familiar with RapidStart Services.\\Do you want to continue?';
        ExcelFileNameTok: Label 'DataImport_Dynamics365%1.xlsx', Comment = '%1 = String generated from current datetime to make sure file names are unique ';
        SettingsMissingQst: Label 'Wait a minute. You have not specified import settings. To avoid extra work and potential errors, we recommend that you specify import settings now, rather than update the data later.\\Do you want to specify the settings?';
        ValidateErrorsBeforeApplyQst: Label 'Some of the fields will not be applied because errors were found in the imported data.\\Do you want to continue?';

    procedure ImportExcelData(): Boolean
    var
        FileManagement: Codeunit "File Management";
        ServerFile: Text[250];
    begin
        OnUploadFile(ServerFile);
        IF ServerFile = '' THEN
            ServerFile := COPYSTR(FileManagement.UploadFile(ImportFromExcelTxt, ExcelFileExtensionTok),
                1, MAXSTRLEN(ServerFile));

        IF ServerFile <> '' THEN BEGIN
            ImportExcelDataByFileName(ServerFile);
            EXIT(TRUE);
        END;

        EXIT(FALSE);
    end;

    procedure ImportExcelDataByFileName(FileName: Text[250])
    var
        FileManagement: Codeunit "File Management";
        Window: Dialog;
    begin
        Window.OPEN(ImportingMsg);

        FileManagement.ValidateFileExtension(FileName, ExcelFileExtensionTok);
        CreatePackageMetadata;
        ValidateTemplateAndImportData(FileName);

        Window.CLOSE;
    end;

    [Scope('Personalization')]
    procedure ImportExcelDataStream(): Boolean
    var
        FileManagement: Codeunit "File Management";
        FileStream: InStream;
        Name: Text;
    begin
        CLEARLASTERROR;

        // There is no way to check if NVInStream is null before using it after calling the
        // UPLOADINTOSTREAM therefore if result is false this is the only way we can throw the error.
        Name := ExcelFileExtensionTok;

        IF NOT UPLOADINTOSTREAM(ImportFromExcelTxt, '', FileManagement.GetToFilterText('', '.xlsx'), Name, FileStream) THEN
            EXIT(FALSE);
        ImportExcelDataByStream(FileStream);
        EXIT(TRUE);
    end;

    [Scope('Personalization')]
    procedure ImportExcelDataByStream(FileStream: InStream)
    var
        Window: Dialog;
    begin
        Window.OPEN(ImportingMsg);

        CreatePackageMetadata;
        ValidateTemplateAndImportDataStream(FileStream);

        Window.CLOSE;
    end;

    procedure ExportExcelTemplate(): Boolean
    var
        FileName: Text;
        HideDialog: Boolean;
    begin
        OnDownloadTemplateAlfa(HideDialog);
        EXIT(ExportExcelTemplateByFileName(FileName, HideDialog));
    end;

    procedure ExportExcelTemplateByFileName(var FileName: Text; HideDialog: Boolean): Boolean
    var
        ConfigPackageTable: Record "Config. Package Table";
    begin
        IF FileName = '' THEN
            FileName :=
              STRSUBSTNO(ExcelFileNameTok, FORMAT(CURRENTDATETIME, 0, '<Day,2>_<Month,2>_<Year4>_<Hours24>_<Minutes,2>_<Seconds,2>'));

        CreatePackageMetadata;
        ConfigPackageTable.SETRANGE("Package Code", PackageCodeTxt);
        ConfigExcelExchange.SetHideDialog(HideDialog);
        EXIT(ConfigExcelExchange.ExportExcel(FileName, ConfigPackageTable, FALSE, TRUE));
    end;

    [Scope('Personalization')]
    procedure GetPackageCode(): Code[20]
    begin
        EXIT(PackageCodeTxt);
    end;

    local procedure CreatePackageMetadata()
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageManagement: Codeunit "Config. Package Management";
        LanguageManagement: Codeunit "LanguageManagement";
        ApplicationSystemConstants: Codeunit "Application System Constants";
    begin
        ConfigPackage.SETRANGE(Code, PackageCodeTxt);
        ConfigPackage.DELETEALL(TRUE);

        ConfigPackageManagement.InsertPackage(ConfigPackage, PackageCodeTxt, PackageNameTxt, FALSE);
        ConfigPackage."Language ID" := LanguageManagement.ApplicationLanguage;
        ConfigPackage."Product Version" :=
          COPYSTR(ApplicationSystemConstants.ApplicationVersion, 1, STRLEN(ConfigPackage."Product Version"));
        ConfigPackage.MODIFY;

        InsertPackageTables;
        InsertPackageFields;
    end;

    local procedure InsertPackageTables()
    var
        ConfigPackageField: Record "Config. Package Field";
        DataMigrationSetup: Record "Data Migration Setup";
    begin
        IF NOT DataMigrationSetup.GET THEN BEGIN
            DataMigrationSetup.INIT;
            DataMigrationSetup.INSERT;
        END;

        InsertPackageTableCustomer(DataMigrationSetup);
        InsertPackageTableVendor(DataMigrationSetup);
        InsertPackageTableItem(DataMigrationSetup);
        InsertPackageTableAccount(DataMigrationSetup);
        InsertPackageTableBankAccount(DataMigrationSetup);
        InsertPackageTableFixedAsset(DataMigrationSetup);
        InsertPackageTableFADepr(DataMigrationSetup);

        ConfigPackageField.SETRANGE("Package Code", PackageCodeTxt);
        ConfigPackageField.MODIFYALL("Include Field", FALSE);
    end;

    local procedure InsertPackageFields()
    begin
        InsertPackageFieldsCustomer;
        InsertPackageFieldsVendor;
        InsertPackageFieldsItem;
        InsertPackageFieldsAccount;
        InsertPackageFieldsBankAccount;
        InsertPackageFieldsFixedAsset;
        InsertPackageFieldsFADepr;
    end;

    local procedure InsertPackageTableCustomer(var DataMigrationSetup: Record "Data Migration Setup")
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigTableProcessingRule: Record "Config. Table Processing Rule";
    begin
        ConfigPackageManagement.InsertPackageTable(ConfigPackageTable, PackageCodeTxt, DATABASE::Customer);
        ConfigPackageTable."Data Template" := DataMigrationSetup."Default Customer Template";
        ConfigPackageTable.MODIFY;
        ConfigPackageManagement.InsertProcessingRuleCustom(
          ConfigTableProcessingRule, ConfigPackageTable, 100000, CODEUNIT::"Excel Post Processor");
    end;

    local procedure InsertPackageFieldsCustomer()
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.SETRANGE("Package Code", PackageCodeTxt);
        ConfigPackageField.SETRANGE("Table ID", DATABASE::Customer);
        ConfigPackageField.DELETEALL(TRUE);

        InsertPackageField(DATABASE::Customer, 1, 1);     // No.
        InsertPackageField(DATABASE::Customer, 2, 2);     // Name
        InsertPackageField(DATABASE::Customer, 3, 3);     // Search Name
        InsertPackageField(DATABASE::Customer, 5, 4);     // Address
        InsertPackageField(DATABASE::Customer, 6, 5);     // Address
        InsertPackageField(DATABASE::Customer, 7, 6);     // City
        InsertPackageField(DATABASE::Customer, 22, 7);    // Currency Code
        InsertPackageField(DATABASE::Customer, 91, 8);    // Post Code
        InsertPackageField(DATABASE::Customer, 35, 9);    // Country/Region Code
        InsertPackageField(DATABASE::Customer, 8, 10);    // Contact
        InsertPackageField(DATABASE::Customer, 9, 11);    // Phone No.
        InsertPackageField(DATABASE::Customer, 102, 12);  // E-Mail
        InsertPackageField(DATABASE::Customer, 20, 13);   // Credit Limit (LCY)
        InsertPackageField(DATABASE::Customer, 21, 14);   // Customer Posting Group
        InsertPackageField(DATABASE::Customer, 27, 15);   // Payment Terms Code
        InsertPackageField(DATABASE::Customer, 88, 16);   // Gen. Bus. Posting Group
        InsertPackageField(Database::Customer, 86, 17);   // VAT Registration No.
        InsertPackageField(Database::Customer, 110, 18);  // VAT Bus. Posting Group.
        InsertPackageField(Database::Customer, 16, 19);   // Global Dimension 1 Code
        InsertPackageField(Database::Customer, 17, 20);   // Global Dimension 2 Code   
    end;

    local procedure InsertPackageTableVendor(var DataMigrationSetup: Record "Data Migration Setup")
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigTableProcessingRule: Record "Config. Table Processing Rule";
    begin
        ConfigPackageManagement.InsertPackageTable(ConfigPackageTable, PackageCodeTxt, DATABASE::Vendor);
        ConfigPackageTable."Data Template" := DataMigrationSetup."Default Vendor Template";
        ConfigPackageTable.MODIFY;
        ConfigPackageManagement.InsertProcessingRuleCustom(
          ConfigTableProcessingRule, ConfigPackageTable, 100000, CODEUNIT::"Excel Post Processor");
    end;

    local procedure InsertPackageFieldsVendor()
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.SETRANGE("Package Code", PackageCodeTxt);
        ConfigPackageField.SETRANGE("Table ID", DATABASE::Vendor);
        ConfigPackageField.DELETEALL(TRUE);

        InsertPackageField(DATABASE::Vendor, 1, 1);     // No.
        InsertPackageField(DATABASE::Vendor, 2, 2);     // Name
        InsertPackageField(DATABASE::Vendor, 3, 3);     // Search Name
        InsertPackageField(DATABASE::Vendor, 5, 4);     // Address
        InsertPackageField(DATABASE::Vendor, 6, 5);     // Address 2
        InsertPackageField(DATABASE::Vendor, 7, 6);     // City
        InsertPackageField(DATABASE::Vendor, 22, 7);    // Currency Code
        InsertPackageField(DATABASE::Vendor, 91, 8);    // Post Code
        InsertPackageField(DATABASE::Vendor, 35, 9);    // Country/Region Code
        InsertPackageField(DATABASE::Vendor, 8, 10);    // Contact
        InsertPackageField(DATABASE::Vendor, 9, 11);    // Phone No.
        InsertPackageField(DATABASE::Vendor, 102, 12);  // E-Mail
        InsertPackageField(DATABASE::Vendor, 21, 13);   // Vendor Posting Group
        InsertPackageField(DATABASE::Vendor, 27, 14);   // Payment Terms Code
        InsertPackageField(DATABASE::Vendor, 88, 15);   // Gen. Bus. Posting Group
        InsertPackageField(Database::Vendor, 86, 16);   // VAT Registration No.
        InsertPackageField(Database::Vendor, 110, 17);  // VAT Bus. Posting Group
        InsertPackageField(Database::Vendor, 16, 18);   // Global Dimension 1 Code
        InsertPackageField(Database::Vendor, 17, 19);   // Global Dimension 1 Code
        InsertPackageField(Database::Vendor, 30, 20);   // Shipment Method Code
        InsertPackageField(Database::Vendor, 31, 21);   // Shipping Agent Code
    end;

    local procedure InsertPackageTableItem(var DataMigrationSetup: Record "Data Migration Setup")
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigTableProcessingRule: Record "Config. Table Processing Rule";
    begin
        ConfigPackageManagement.InsertPackageTable(ConfigPackageTable, PackageCodeTxt, DATABASE::Item);
        ConfigPackageTable."Data Template" := DataMigrationSetup."Default Item Template";
        ConfigPackageTable.MODIFY;
        ConfigPackageManagement.InsertProcessingRuleCustom(
          ConfigTableProcessingRule, ConfigPackageTable, 100000, CODEUNIT::"Excel Post Processor")
    end;

    local procedure InsertPackageFieldsItem()
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.SETRANGE("Package Code", PackageCodeTxt);
        ConfigPackageField.SETRANGE("Table ID", DATABASE::Item);
        ConfigPackageField.DELETEALL(TRUE);

        InsertPackageField(DATABASE::Item, 1, 1);     // No.
        InsertPackageField(DATABASE::Item, 3, 2);     // Description
        InsertPackageField(DATABASE::Item, 4, 3);     // Search Description
        InsertPackageField(DATABASE::Item, 8, 4);     // Base Unit of Measure
        InsertPackageField(DATABASE::Item, 18, 5);    // Unit Price
        InsertPackageField(DATABASE::Item, 22, 6);    // Unit Cost
        InsertPackageField(DATABASE::Item, 24, 7);    // Standard Cost
        InsertPackageField(DATABASE::Item, 11, 8);    // Inventory Posting Group
        InsertPackageField(DATABASE::Item, 21, 9);    // Costing Method
        InsertPackageField(DATABASE::Item, 31, 10);   // Vendor No.
        InsertPackageField(DATABASE::Item, 32, 11);   // Vendor Item No.
        InsertPackageField(DATABASE::Item, 91, 12);   // Gen. Prod. Posting Group
        InsertPackageField(DATABASE::Item, 99, 13);   // VAT Prod. Posting Group
        InsertPackageField(DATABASE::Item, 105, 14);  // Global Dimension 1 Code
        InsertPackageField(DATABASE::Item, 106, 15);  // Global Dimension 2 Code
        InsertPackageField(DATABASE::Item, 5425, 16); // Sales Unit of Measure
        InsertPackageField(DATABASE::Item, 5426, 17); // Purch. Unit of Measure
        InsertPackageField(DATABASE::Item, 5702, 18); // Item Category Code
        InsertPackageField(DATABASE::Item, 5704, 19); // Product Group Code
    end;

    local procedure InsertPackageTableBankAccount(var DataMigrationSetup: Record "Data Migration Setup")
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigTableProcessingRule: Record "Config. Table Processing Rule";
    begin
        ConfigPackageManagement.InsertPackageTable(ConfigPackageTable, PackageCodeTxt, DATABASE::"Bank Account");
        ConfigPackageTable."Data Template" := DataMigrationSetup."Default Customer Template";
        ConfigPackageTable.MODIFY;
        ConfigPackageManagement.InsertProcessingRuleCustom(
          ConfigTableProcessingRule, ConfigPackageTable, 100000, CODEUNIT::"Excel Post Processor");
    end;

    local procedure InsertPackageFieldsBankAccount()
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.SETRANGE("Package Code", PackageCodeTxt);
        ConfigPackageField.SETRANGE("Table ID", DATABASE::"Bank Account");
        ConfigPackageField.DELETEALL(TRUE);

        InsertPackageField(DATABASE::"Bank Account", 1, 1);     // No.
        InsertPackageField(DATABASE::"Bank Account", 2, 2);     // Name
        InsertPackageField(DATABASE::"Bank Account", 3, 3);     // Search Name
        InsertPackageField(DATABASE::"Bank Account", 5, 4);     // Address
        InsertPackageField(DATABASE::"Bank Account", 6, 5);     // Address 2
        InsertPackageField(DATABASE::"Bank Account", 7, 6);     // City
        InsertPackageField(DATABASE::"Bank Account", 91, 7);    // Post Code
        InsertPackageField(DATABASE::"Bank Account", 35, 8);    // Country/Region Code
        InsertPackageField(DATABASE::"Bank Account", 8, 9);     // Contact
        InsertPackageField(DATABASE::"Bank Account", 9, 10);    // Phone No.
        InsertPackageField(DATABASE::"Bank Account", 102, 11);  // E-Mail
        InsertPackageField(DATABASE::"Bank Account", 101, 12);  // Bank Branch No
        InsertPackageField(DATABASE::"Bank Account", 13, 13);   // Bank Account No
        InsertPackageField(DATABASE::"Bank Account", 110, 14);  // IBAN
        InsertPackageField(DATABASE::"Bank Account", 22, 15);   // Currency
        InsertPackageField(DATABASE::"Bank Account", 21, 16);   // Bank Acc. Posting Group
        InsertPackageField(DATABASE::"Bank Account", 16, 17);   // Global Dimension 1 Code
        InsertPackageField(DATABASE::"Bank Account", 17, 18);   // Global Dimension 2 Code 
    end;

    local procedure InsertPackageTableFixedAsset(var DataMigrationSetup: Record "Data Migration Setup")
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigTableProcessingRule: Record "Config. Table Processing Rule";
    begin
        ConfigPackageManagement.InsertPackageTable(ConfigPackageTable, PackageCodeTxt, DATABASE::"Fixed Asset");
        ConfigPackageTable."Data Template" := DataMigrationSetup."Default Customer Template";
        ConfigPackageTable.MODIFY;
        ConfigPackageManagement.InsertProcessingRuleCustom(
          ConfigTableProcessingRule, ConfigPackageTable, 100000, CODEUNIT::"Excel Post Processor");
    end;

    local procedure InsertPackageFieldsFixedAsset()
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.SETRANGE("Package Code", PackageCodeTxt);
        ConfigPackageField.SETRANGE("Table ID", DATABASE::"Fixed Asset");
        ConfigPackageField.DELETEALL(TRUE);

        InsertPackageField(DATABASE::"Fixed Asset", 1, 1);     // No.
        InsertPackageField(DATABASE::"Fixed Asset", 2, 2);     // Description
        InsertPackageField(DATABASE::"Fixed Asset", 3, 3);     // Search Description
        InsertPackageField(DATABASE::"Fixed Asset", 5, 4);     // Class
        InsertPackageField(DATABASE::"Fixed Asset", 6, 5);     // SubClass
        InsertPackageField(DATABASE::"Fixed Asset", 10, 6);    // FA Location
        InsertPackageField(DATABASE::"Fixed Asset", 11, 7);    // Vendor No
        InsertPackageField(DATABASE::"Fixed Asset", 16, 8);    // Responsible Employee
        InsertPackageField(DATABASE::"Fixed Asset", 17, 9);    // Serial No.
        InsertPackageField(DATABASE::"Fixed Asset", 23, 10);   // Maintenance Vendor No.
        InsertPackageField(DATABASE::"Fixed Asset", 29, 11);   // FA Posting Group
    end;

    local procedure InsertPackageTableFADepr(var DataMigrationSetup: Record "Data Migration Setup")
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigTableProcessingRule: Record "Config. Table Processing Rule";
    begin
        ConfigPackageManagement.InsertPackageTable(ConfigPackageTable, PackageCodeTxt, DATABASE::"FA Depreciation Book");
        ConfigPackageTable."Data Template" := DataMigrationSetup."Default Customer Template";
        ConfigPackageTable.MODIFY;
        ConfigPackageManagement.InsertProcessingRuleCustom(
          ConfigTableProcessingRule, ConfigPackageTable, 100000, CODEUNIT::"Excel Post Processor");
    end;

    local procedure InsertPackageFieldsFADepr()
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.SETRANGE("Package Code", PackageCodeTxt);
        ConfigPackageField.SETRANGE("Table ID", DATABASE::"FA Depreciation Book");
        ConfigPackageField.DELETEALL(TRUE);

        InsertPackageField(DATABASE::"FA Depreciation Book", 1, 1);     // FA No.
        InsertPackageField(DATABASE::"FA Depreciation Book", 2, 2);     // Depreciation Book Code
        InsertPackageField(DATABASE::"FA Depreciation Book", 3, 3);     // Depreciation Method
        InsertPackageField(DATABASE::"FA Depreciation Book", 4, 4);     // Depreciation Starting Date
        InsertPackageField(DATABASE::"FA Depreciation Book", 6, 5);     // No. of Depreciation Years
        InsertPackageField(DATABASE::"FA Depreciation Book", 7, 6);     // No. of Depreciation Months
        InsertPackageField(DATABASE::"FA Depreciation Book", 13, 7);    // FA Posting Group
        InsertPackageField(DATABASE::"FA Depreciation Book", 55, 8);    // Description
    end;

    local procedure InsertPackageField(TableNo: Integer; FieldNo: Integer; ProcessingOrderNo: Integer)
    var
        ConfigPackageField: Record "Config. Package Field";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
    begin
        RecordRef.OPEN(TableNo);
        FieldRef := RecordRef.FIELD(FieldNo);

        ConfigPackageManagement.InsertPackageField(ConfigPackageField, PackageCodeTxt, TableNo,
          FieldRef.NUMBER, FieldRef.NAME, FieldRef.CAPTION, TRUE, TRUE, FALSE, FALSE);
        ConfigPackageField.VALIDATE("Processing Order", ProcessingOrderNo);
        ConfigPackageField.MODIFY(TRUE);
    end;

    local procedure GetCodeunitNumber(): Integer
    begin
        EXIT(CODEUNIT::"Alfa Excel Data Migrator");
    end;

    local procedure ValidateTemplateAndImportData(FileName: Text)
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        ConfigPackage: Record "Config. Package";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackage.GET(PackageCodeTxt);
        ConfigPackageTable.SETRANGE("Package Code", ConfigPackage.Code);

        IF ConfigPackageTable.FINDSET THEN
            REPEAT
                ConfigPackageField.RESET;

                // Check if Excel file contains data sheets with the supported master tables (Customer, Vendor, Item)
                IF IsTableInExcel(TempExcelBuffer, FileName, ConfigPackageTable) THEN
                    ValidateTemplateAndImportDataCommon(TempExcelBuffer, ConfigPackageField, ConfigPackageTable)
                ELSE BEGIN
                    // Table is removed from the configuration package because it doen't exist in the Excel file
                    TempExcelBuffer.CloseBook;
                    ConfigPackageTable.DELETE(TRUE);
                END;
            UNTIL ConfigPackageTable.NEXT = 0;
    end;

    local procedure ValidateTemplateAndImportDataStream(FileStream: InStream)
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        ConfigPackage: Record "Config. Package";
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackage.GET(PackageCodeTxt);
        ConfigPackageTable.SETRANGE("Package Code", ConfigPackage.Code);

        IF ConfigPackageTable.FINDSET THEN
            REPEAT
                ConfigPackageField.RESET;

                // Check if Excel file contains data sheets with the supported master tables (Customer, Vendor, Item)
                IF IsTableInExcelStream(TempExcelBuffer, FileStream, ConfigPackageTable) THEN
                    ValidateTemplateAndImportDataCommon(TempExcelBuffer, ConfigPackageField, ConfigPackageTable)
                ELSE BEGIN
                    // Table is removed from the configuration package because it doen't exist in the Excel file
                    TempExcelBuffer.CloseBook;
                    ConfigPackageTable.DELETE(TRUE);
                END;
            UNTIL ConfigPackageTable.NEXT = 0;
    end;

    local procedure ValidateTemplateAndImportDataCommon(var TempExcelBuffer: Record "Excel Buffer" temporary; var ConfigPackageField: Record "Config. Package Field"; var ConfigPackageTable: Record "Config. Package Table")
    var
        ConfigPackageRecord: Record "Config. Package Record";
        ColumnHeaderRow: Integer;
        ColumnCount: Integer;
        RecordNo: Integer;
        FieldID: array[250] of Integer;
        I: Integer;
    begin
        ColumnHeaderRow := 3; // Data is stored in the Excel sheets starting from row 3

        TempExcelBuffer.ReadSheet;
        // Jump to the Columns' header row
        TempExcelBuffer.SETFILTER("Row No.", '%1..', ColumnHeaderRow);

        ConfigPackageField.SETRANGE("Package Code", PackageCodeTxt);
        ConfigPackageField.SETRANGE("Table ID", ConfigPackageTable."Table ID");

        ColumnCount := 0;

        IF TempExcelBuffer.FINDSET THEN
            REPEAT
                IF TempExcelBuffer."Row No." = ColumnHeaderRow THEN BEGIN // Columns' header row
                    ConfigPackageField.SETRANGE("Field Caption", TempExcelBuffer."Cell Value as Text");

                    // Column can be mapped to a field, data will be imported to NAV
                    IF ConfigPackageField.FINDFIRST THEN BEGIN
                        FieldID[TempExcelBuffer."Column No."] := ConfigPackageField."Field ID";
                        ConfigPackageField."Include Field" := TRUE;
                        ConfigPackageField.MODIFY;
                        ColumnCount += 1;
                    END ELSE // Error is thrown when the template is corrupted (i.e., there are columns in Excel file that cannot be mapped to NAV)
                        ERROR(ExcelValidationErr, PRODUCTNAME.MARKETING);
                END ELSE BEGIN // Read data row by row
                               // A record is created with every new row
                    ConfigPackageManagement.InitPackageRecord(ConfigPackageRecord, PackageCodeTxt,
                      ConfigPackageTable."Table ID");
                    RecordNo := ConfigPackageRecord."No.";
                    IF ConfigPackageTable."Table ID" = 15 THEN BEGIN
                        FOR I := 1 TO ColumnCount DO
                            IF TempExcelBuffer.GET(TempExcelBuffer."Row No.", I) THEN // Mapping for Account fields
                                InsertAccountsFieldData(ConfigPackageTable."Table ID", RecordNo, FieldID[I], TempExcelBuffer."Cell Value as Text")
                    END ELSE BEGIN
                        FOR I := 1 TO ColumnCount DO
                            IF TempExcelBuffer.GET(TempExcelBuffer."Row No.", I) THEN
                                // Fields are populated in the record created
                                InsertFieldData(
                                  ConfigPackageTable."Table ID", RecordNo, FieldID[I], TempExcelBuffer."Cell Value as Text")
                            ELSE
                                InsertFieldData(
                                  ConfigPackageTable."Table ID", RecordNo, FieldID[I], '');
                    END;

                    // Go to next line
                    TempExcelBuffer.SETFILTER("Row No.", '%1..', TempExcelBuffer."Row No." + 1);
                END;
            UNTIL TempExcelBuffer.NEXT = 0;

        TempExcelBuffer.RESET;
        TempExcelBuffer.DELETEALL;
        TempExcelBuffer.CloseBook;
    end;

    [TryFunction]
    local procedure IsTableInExcel(var TempExcelBuffer: Record "Excel Buffer" temporary; FileName: Text; ConfigPackageTable: Record "Config. Package Table")
    begin
        ConfigPackageTable.CALCFIELDS("Table Name", "Table Caption");

        IF NOT TryOpenExcel(TempExcelBuffer, FileName, ConfigPackageTable."Table Name") THEN
            TryOpenExcel(TempExcelBuffer, FileName, ConfigPackageTable."Table Caption");
    end;

    [TryFunction]
    local procedure TryOpenExcel(var TempExcelBuffer: Record "Excel Buffer" temporary; FileName: Text; SheetName: Text[250])
    begin
        TempExcelBuffer.OpenBook(FileName, SheetName);
    end;

    local procedure IsTableInExcelStream(var TempExcelBuffer: Record "Excel Buffer" temporary; FileStream: InStream; ConfigPackageTable: Record "Config. Package Table"): Boolean
    begin
        ConfigPackageTable.CALCFIELDS("Table Name", "Table Caption");

        IF OpenExcelStream(TempExcelBuffer, FileStream, ConfigPackageTable."Table Name") = '' THEN
            EXIT(TRUE);
        IF OpenExcelStream(TempExcelBuffer, FileStream, ConfigPackageTable."Table Caption") = '' THEN
            EXIT(TRUE);
        EXIT(FALSE);
    end;

    local procedure OpenExcelStream(var TempExcelBuffer: Record "Excel Buffer" temporary; FileStream: InStream; SheetName: Text[250]): Text
    begin
        EXIT(TempExcelBuffer.OpenBookStream(FileStream, SheetName));
    end;

    local procedure InsertFieldData(TableNo: Integer; RecordNo: Integer; FieldNo: Integer; Value: Text[250])
    var
        ConfigPackageData: Record "Config. Package Data";
    begin
        ConfigPackageManagement.InsertPackageData(ConfigPackageData, PackageCodeTxt,
          TableNo, RecordNo, FieldNo, Value, FALSE);
    end;

    local procedure CreateDataMigrationEntites(var DataMigrationEntity: Record "Data Migration Entity")
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageTable: Record "Config. Package Table";
    begin
        ConfigPackage.GET(PackageCodeTxt);
        ConfigPackageTable.SETRANGE("Package Code", ConfigPackage.Code);
        DataMigrationEntity.DELETEALL;

        WITH ConfigPackageTable DO
            IF FINDSET THEN
                REPEAT
                    CALCFIELDS("No. of Package Records");
                    DataMigrationEntity.InsertRecord("Table ID", "No. of Package Records");
                UNTIL NEXT = 0;
    end;

    [EventSubscriber(ObjectType::Table, 70140952, 'OnRegisterDataMigratorAlfa', '', false, false)]
    local procedure RegisterExcelDataMigratorAlfa(var Sender: Record "Alfa DataMigrator Registration")
    begin
        Sender.RegisterDataMigrator(GetCodeunitNumber, DataMigratorDescriptionTxt);
    end;

    [EventSubscriber(ObjectType::Table, 70140952, 'OnHasSettingsAlfa', '', false, false)]
    local procedure HasSettingsAlfa(var Sender: Record "Alfa DataMigrator Registration"; var HasSettings: Boolean)
    begin
        IF Sender."No." <> GetCodeunitNumber THEN
            EXIT;

        HasSettings := TRUE;
    end;

    [EventSubscriber(ObjectType::Table, 70140952, 'OnOpenSettingsAlfa', '', false, false)]
    local procedure OpenSettingsAlfa(var Sender: Record "Alfa DataMigrator Registration"; var Handled: Boolean)
    begin
        IF Sender."No." <> GetCodeunitNumber THEN
            EXIT;

        PAGE.RUNMODAL(PAGE::"Data Migration Settings");
        Handled := TRUE;
    end;

    [EventSubscriber(ObjectType::Table, 70140952, 'OnValidateSettingsAlfa', '', false, false)]
    local procedure ValidateSettingsAlfa(var Sender: Record "Alfa DataMigrator Registration")
    var
        DataMigrationSetup: Record "Data Migration Setup";
    begin
        IF Sender."No." <> GetCodeunitNumber THEN
            EXIT;

        DataMigrationSetup.GET;
        IF (DataMigrationSetup."Default Customer Template" = '') AND
           (DataMigrationSetup."Default Vendor Template" = '') AND
           (DataMigrationSetup."Default Item Template" = '')
        THEN
            IF CONFIRM(SettingsMissingQst, TRUE) THEN
                PAGE.RUNMODAL(PAGE::"Data Migration Settings");
    end;

    [EventSubscriber(ObjectType::Table, 70140952, 'OnHasTemplateAlfa', '', false, false)]
    local procedure HasTemplate(var Sender: Record "Alfa DataMigrator Registration"; var HasTemplate: Boolean)
    begin
        IF Sender."No." <> GetCodeunitNumber THEN
            EXIT;

        HasTemplate := TRUE;
    end;

    [EventSubscriber(ObjectType::Table, 70140952, 'OnGetInstructionsAlfa', '', false, false)]
    local procedure GetInstructions(var Sender: Record "Alfa DataMigrator Registration"; var Instructions: Text; var Handled: Boolean)
    var
        CRLF: Text[2];
    begin
        IF Sender."No." <> GetCodeunitNumber THEN
            EXIT;

        CRLF := '';
        CRLF[1] := 13;
        CRLF[2] := 10;

        Instructions := Instruction1Txt + CRLF + Instruction2Txt + CRLF + Instruction3Txt + CRLF + Instruction4Txt;

        Handled := TRUE;
    end;

    [EventSubscriber(ObjectType::Table, 70140952, 'OnDownloadTemplateAlfa', '', false, false)]
    local procedure DownloadTemplateAlfa(var Sender: Record "Alfa DataMigrator Registration"; var Handled: Boolean)
    begin
        IF Sender."No." <> GetCodeunitNumber THEN
            EXIT;

        IF ExportExcelTemplate THEN BEGIN
            Handled := TRUE;
            EXIT;
        END;
    end;

    [EventSubscriber(ObjectType::Table, 70140952, 'OnDataImportAlfa', '', false, false)]
    local procedure ImportData(var Sender: Record "Alfa DataMigrator Registration"; var Handled: Boolean)
    begin
        IF Sender."No." <> GetCodeunitNumber THEN
            EXIT;

        IF ImportExcelData THEN BEGIN
            Handled := TRUE;
            EXIT;
        END;

        Handled := FALSE;
    end;

    [EventSubscriber(ObjectType::Table, 70140952, 'OnSelectDataToApplyAlfa', '', false, false)]
    local procedure SelectDataToApply(var Sender: Record "Alfa DataMigrator Registration"; var DataMigrationEntity: Record "Data Migration Entity"; var Handled: Boolean)
    begin
        IF Sender."No." <> GetCodeunitNumber THEN
            EXIT;

        CreateDataMigrationEntites(DataMigrationEntity);

        Handled := TRUE;
    end;

    [EventSubscriber(ObjectType::Table, 70140952, 'OnHasAdvancedApplyAlfa', '', false, false)]
    local procedure HasAdvancedApply(var Sender: Record "Alfa DataMigrator Registration"; var HasAdvancedApply: Boolean)
    begin
        IF Sender."No." <> GetCodeunitNumber THEN
            EXIT;

        HasAdvancedApply := FALSE;
    end;

    [EventSubscriber(ObjectType::Table, 70140952, 'OnOpenAdvancedApplyAlfa', '', false, false)]
    local procedure OpenAdvancedApply(var Sender: Record "Alfa DataMigrator Registration"; var DataMigrationEntity: Record "Data Migration Entity"; var Handled: Boolean)
    var
        ConfigPackage: Record "Config. Package";
    begin
        IF Sender."No." <> GetCodeunitNumber THEN
            EXIT;

        IF NOT CONFIRM(OpenAdvancedQst, TRUE) THEN
            EXIT;

        ConfigPackage.GET(PackageCodeTxt);
        PAGE.RUNMODAL(PAGE::"Config. Package Card", ConfigPackage);

        CreateDataMigrationEntites(DataMigrationEntity);
        Handled := TRUE;
    end;

    [EventSubscriber(ObjectType::Table, 70140952, 'OnApplySelectedDataAlfa', '', false, false)]
    local procedure ApplySelectedData(var Sender: Record "Alfa DataMigrator Registration"; var DataMigrationEntity: Record "Data Migration Entity"; var Handled: Boolean)
    var
        ConfigPackage: Record "Config. Package";
        ConfigPackageTable: Record "Config. Package Table";
        TempConfigPackageTable: Record "Config. Package Table" temporary;
        ConfigPackageManagement: Codeunit "Config. Package Management";
        Window: Dialog;
    begin
        IF Sender."No." <> GetCodeunitNumber THEN
            EXIT;

        ConfigPackage.GET(PackageCodeTxt);
        ConfigPackageTable.SETRANGE("Package Code", ConfigPackage.Code);

        // Validate the package
        ConfigPackageManagement.SetHideDialog(TRUE);
        ConfigPackageManagement.CleanPackageErrors(PackageCodeTxt, '');
        DataMigrationEntity.SETRANGE(Selected, TRUE);
        IF DataMigrationEntity.FINDSET THEN
            REPEAT
                ConfigPackageTable.SETRANGE("Table ID", DataMigrationEntity."Table ID");
                ConfigPackageManagement.ValidatePackageRelations(ConfigPackageTable, TempConfigPackageTable, TRUE);
            UNTIL DataMigrationEntity.NEXT = 0;
        DataMigrationEntity.SETRANGE(Selected);
        ConfigPackageTable.SETRANGE("Table ID");
        ConfigPackageManagement.SetHideDialog(FALSE);
        ConfigPackage.CALCFIELDS("No. of Errors");
        ConfigPackageManagement.CleanPackageErrors(PackageCodeTxt, '');

        IF ConfigPackage."No. of Errors" <> 0 THEN
            IF NOT CONFIRM(ValidateErrorsBeforeApplyQst) THEN
                EXIT;

        IF DataMigrationEntity.FINDSET THEN
            REPEAT
                IF NOT DataMigrationEntity.Selected THEN BEGIN
                    ConfigPackageTable.GET(PackageCodeTxt, DataMigrationEntity."Table ID");
                    ConfigPackageTable.DELETE(TRUE);
                END;
            UNTIL DataMigrationEntity.NEXT = 0;

        Window.OPEN(ApplyingMsg);
        RemoveDemoData(ConfigPackageTable);// Remove the demo data before importing Accounts(if any)
        ConfigPackageManagement.ApplyPackage(ConfigPackage, ConfigPackageTable, TRUE);
        Window.CLOSE;
        Handled := TRUE;
    end;

    [EventSubscriber(ObjectType::Table, 70140952, 'OnHasErrorsAlfa', '', false, false)]
    local procedure HasErrors(var Sender: Record "Alfa DataMigrator Registration"; var HasErrors: Boolean)
    var
        ConfigPackage: Record "Config. Package";
    begin
        IF Sender."No." <> GetCodeunitNumber THEN
            EXIT;

        ConfigPackage.GET(PackageCodeTxt);
        ConfigPackage.CALCFIELDS("No. of Errors");
        HasErrors := ConfigPackage."No. of Errors" <> 0;
    end;

    [EventSubscriber(ObjectType::Table, 70140952, 'OnShowErrorsAlfa', '', false, false)]
    local procedure ShowErrors(var Sender: Record "Alfa DataMigrator Registration"; var Handled: Boolean)
    var
        ConfigPackageError: Record "Config. Package Error";
    begin
        IF Sender."No." <> GetCodeunitNumber THEN
            EXIT;

        ConfigPackageError.SETRANGE("Package Code", PackageCodeTxt);
        PAGE.RUNMODAL(PAGE::"Config. Package Errors", ConfigPackageError);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUploadFile(var ServerFileName: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDownloadTemplateAlfa(var HideDialog: Boolean)
    begin
    end;

    local procedure InsertPackageTableAccount(var DataMigrationSetup: Record "Data Migration Setup")
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigTableProcessingRule: Record "Config. Table Processing Rule";
    begin
        ConfigPackageManagement.InsertPackageTable(ConfigPackageTable, PackageCodeTxt, DATABASE::"G/L Account");
        ConfigPackageTable."Data Template" := DataMigrationSetup."Default Account Template";
        ConfigPackageTable.MODIFY;
        ConfigPackageManagement.InsertProcessingRuleCustom(
          ConfigTableProcessingRule, ConfigPackageTable, 100000, CODEUNIT::"Excel Post Processor");
    end;

    local procedure InsertPackageFieldsAccount()
    var
        ConfigPackageField: Record "Config. Package Field";
    begin
        ConfigPackageField.SETRANGE("Package Code", PackageCodeTxt);
        ConfigPackageField.SETRANGE("Table ID", DATABASE::"G/L Account");
        ConfigPackageField.DELETEALL(TRUE);

        InsertPackageField(DATABASE::"G/L Account", 1, 1);     // No.
        InsertPackageField(DATABASE::"G/L Account", 2, 2);     // Name
        InsertPackageField(DATABASE::"G/L Account", 3, 3);     // Search Name
        InsertPackageField(DATABASE::"G/L Account", 4, 4);     // Account Type
        InsertPackageField(DATABASE::"G/L Account", 8, 5);     // Account Category
        InsertPackageField(DATABASE::"G/L Account", 9, 6);     // Income/Balance
        InsertPackageField(DATABASE::"G/L Account", 10, 7);    // Debit/Credit
        InsertPackageField(DATABASE::"G/L Account", 13, 8);    // Blocked
        InsertPackageField(DATABASE::"G/L Account", 43, 9);   // Gen. Posting Type
        InsertPackageField(DATABASE::"G/L Account", 44, 10);   // Gen. Bus. Posting Group
        InsertPackageField(DATABASE::"G/L Account", 45, 11);   // Gen. Prod. Posting Group
        InsertPackageField(DATABASE::"G/L Account", 80, 12);   // Account Subcategory Entry No.
    end;

    local procedure RemoveDemoData(var ConfigPackageTable: Record "Config. Package Table")
    var
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageRecord: Record "Config. Package Record";
    begin
        IF ConfigPackageTable.GET(PackageCodeTxt, DATABASE::"G/L Account") THEN BEGIN
            ConfigPackageRecord.SETRANGE("Package Code", ConfigPackageTable."Package Code");
            ConfigPackageRecord.SETRANGE("Table ID", ConfigPackageTable."Table ID");
            IF ConfigPackageRecord.FINDFIRST THEN BEGIN
                ConfigPackageData.SETRANGE("Package Code", ConfigPackageRecord."Package Code");
                ConfigPackageData.SETRANGE("Table ID", ConfigPackageRecord."Table ID");
                IF ConfigPackageData.FINDFIRST THEN
                    CODEUNIT.RUN(CODEUNIT::"Data Migration Del G/L Account");
            END;
        END;
    end;

    local procedure InsertAccountsFieldData(TableNo: Integer; RecordNo: Integer; FieldNo: Integer; Value: Text[250])
    var
        GLAccount: Record "G/L Account";
    begin
        IF FieldNo = 4 THEN BEGIN
            IF Value = '0' THEN
                InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Account Type"::Posting))
            ELSE
                IF Value = '1' THEN
                    InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Account Type"::Heading))
                ELSE
                    IF Value = '2' THEN
                        InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Account Type"::Total))
                    ELSE
                        IF Value = '3' THEN
                            InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Account Type"::"Begin-Total"))
                        ELSE
                            IF Value = '4' THEN
                                InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Account Type"::"End-Total"))
        END ELSE
            IF FieldNo = 8 THEN BEGIN
                IF Value = '0' THEN
                    InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Account Category"::" "))
                ELSE
                    IF Value = '1' THEN
                        InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Account Category"::Assets))
                    ELSE
                        IF Value = '2' THEN
                            InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Account Category"::Liabilities))
                        ELSE
                            IF Value = '3' THEN
                                InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Account Category"::Equity))
                            ELSE
                                IF Value = '4' THEN
                                    InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Account Category"::Income))
                                ELSE
                                    IF Value = '5' THEN
                                        InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Account Category"::"Cost of Goods Sold"))
                                    ELSE
                                        IF Value = '6' THEN
                                            InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Account Category"::Expense))
            END ELSE
                IF FieldNo = 9 THEN BEGIN
                    IF Value = '0' THEN
                        InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Income/Balance"::"Income Statement"))
                    ELSE
                        IF Value = '1' THEN
                            InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Income/Balance"::"Balance Sheet"))
                END ELSE
                    IF FieldNo = 10 THEN BEGIN
                        IF Value = '0' THEN
                            InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Debit/Credit"::Both))
                        ELSE
                            IF Value = '1' THEN
                                InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Debit/Credit"::Debit))
                            ELSE
                                IF Value = '2' THEN
                                    InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Debit/Credit"::Credit))
                    END ELSE
                        IF FieldNo = 43 THEN BEGIN
                            IF Value = '0' THEN
                                InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Gen. Posting Type"::" "))
                            ELSE
                                IF Value = '1' THEN
                                    InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Gen. Posting Type"::Purchase))
                                ELSE
                                    IF Value = '2' THEN
                                        InsertFieldData(TableNo, RecordNo, FieldNo, FORMAT(GLAccount."Gen. Posting Type"::Sale))
                        END ELSE
                            InsertFieldData(TableNo, RecordNo, FieldNo, Value)
    end;
}

