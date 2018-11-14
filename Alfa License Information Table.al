
table 70140953 "Alfa License"
{
    Caption = 'AlfaZance License Info';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    ReplicateData = false;
    fields
    {
        field(1; "Product ID"; Code[20])
        {
            Caption = 'Product ID';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "License Key"; Text[250])
        {
            Caption = 'License Key';
            DataClassification = CustomerContent;
        }
        field(4; "Expiry Date"; Date)
        {
            Caption = 'Expiry Date';
            DataClassification = CustomerContent;
        }
        field(5; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
        }
        field(6; "No. of Legal Entity Allowed"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'No. of Legal Entity Allowed';
            trigger OnValidate()
            begin
                CalcFields("No. of Legal Entity Used");
                "No. of Legal Entity Remaining" := "No. of Legal Entity Allowed" - "No. of Legal Entity Used";
            ENd;
        }
        field(7; "No. of Legal Entity Used"; integer)
        {
            Caption = 'No. of Legal Entity Used';
            FieldClass = FlowField;
            CalcFormula = count ("Alfa License Line" where ("Product Id" = field ("Product ID")));
        }
        field(8; "No. of Legal Entity Remaining"; integer)
        {
            DataClassification = CustomerContent;
            Caption = 'No. of Legal Entity Remaining';

        }
        field(10; "Date of import"; Date)
        {
            Caption = 'Date of Import';
            DataClassification = CustomerContent;
        }
        field(11; "User ID"; Text[50])
        {
            Caption = 'User ID';
            TableRelation = User;
            ValidateTableRelation = True;
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(PK; "Product ID")
        {
            Clustered = true;
        }
    }

    var
        AlfaLicenseLine: Record "Alfa License Line";
        LineNo: integer;

    trigger OnInsert()
    begin
        "Date of import" := Today();
        "User ID" := UserId();
        AlfaLicenseLine.RESET;
        AlfaLicenseLine.SetRange("Product Id", "Product ID");
        IF AlfaLicenseLine.FindLast() then
            LineNo := AlfaLicenseLine."Line No."
        ELSE
            LineNo := 10000;
        AlfaLicenseLine.Init();
        AlfaLicenseLine."Product Id" := "Product ID";
        AlfaLicenseLine."Line No." := LineNo;
        AlfaLicenseLine."Company Name" := CompanyName();
        AlfaLicenseLine."Created Date" := Today;
        AlfaLicenseLine.Insert();
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure CheckLicense(ProductId: Code[20]; LicenseKey: Text[250]): Boolean
    var
        VoiceAccountNo: code[10];
        ExpiryDate: Date;
        NoOfLegalEntity: integer;
        LicenseInformation: Record "License Information";
        LicVoiceAccNo: Code[10];
        AlfaLicense: Record "Alfa License";
    begin
        If LicenseKey = '' THEN
            Error('Please enter licensce key');
        DecryptLicenseKey(LicenseKey, VoiceAccountNo, ExpiryDate, NoOfLegalEntity);
        IF (ExpiryDate < Today()) THEN
            Error('License is already Expired');
        If (NoOfLegalEntity = 0) THEN
            Error('License is not valid for 0 legal entity');
        LicenseInformation.Reset();
        LicenseInformation.SetRange("Line No.", 4);
        IF LicenseInformation.FindFirst() THEN begin
            LicVoiceAccNo := CopyStr(LicenseInformation.Text, StrPos(LicenseInformation.Text, ':') + 2, 10);
            If LicVoiceAccNo <> VoiceAccountNo then
                Error('License is invalid');
        END;
        If NOT AlfaLicense.Get("Product ID") THEN
            Exit(true);
        AlfaLicense.CalcFields("No. of Legal Entity Remaining");
        If AlfaLicense."No. of Legal Entity Remaining" <= 0 THEN
            Error('License is reached the limit of legal entities');
        Exit(True);
    end;

    procedure DecryptLicenseKey(LicenseKey: Text[250]; Var VoiceAccountNo: Code[10]; var ExpiryDate: Date; var NoOfLegalEntity: Integer)
    var
        LicenseInformation: Record "License Information";
    Begin
        LicenseInformation.Reset();
        LicenseInformation.SetRange("Line No.", 4);
        IF LicenseInformation.FindFirst() THEN
            VoiceAccountNo := CopyStr(LicenseInformation.Text, StrPos(LicenseInformation.Text, ':') + 2, 10);
        ExpiryDate := DMY2Date(31, 12, 2019);
        NoOfLegalEntity := 2;
    End;

    procedure ImportLicense(ProductID: Code[20]; LicenseKey: Text[250]; CustomerName: Text[100]; ProductDesc: Text[100])
    var
        AlfaLicenseInfo: Record "Alfa License";
        VoiceAccountNo: code[10];
        ExpiryDate: Date;
        NoOfLegalEntity: integer;
    Begin
        DecryptLicenseKey(LicenseKey, VoiceAccountNo, ExpiryDate, NoOfLegalEntity);
        If AlfaLicenseInfo.Get(ProductID) THEN BEGIN
            AlfaLicenseInfo."License Key" := LicenseKey;
            AlfaLicenseInfo."Expiry Date" := ExpiryDate;
            AlfaLicenseInfo.Validate("No. of Legal Entity Allowed", NoOfLegalEntity);
            AlfaLicenseInfo."Date of import" := Today();
            AlfaLicenseInfo."User ID" := UserId();
            AlfaLicenseInfo.Modify();
        END ELSE BEGIN
            AlfaLicenseInfo.Init();
            AlfaLicenseInfo."Product ID" := ProductID;
            AlfaLicenseInfo."License Key" := LicenseKey;
            AlfaLicenseInfo."Expiry Date" := ExpiryDate;
            AlfaLicenseInfo.Validate("No. of Legal Entity Allowed", NoOfLegalEntity);
            AlfaLicenseInfo."No. of Legal Entity Remaining" := 0;
            AlfaLicenseInfo."Customer Name" := CustomerName;
            AlfaLicenseInfo.Description := ProductDesc;
            AlfaLicenseInfo.Insert(True);
        END;
    End;
}
table 70140954 "Alfa License Line"
{
    DataClassification = CustomerContent;
    Caption = 'Alfa License Legal Entity Info';
    DataPerCompany = false;
    ReplicateData = false;
    fields
    {
        field(1; "Product Id"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Product Id';
            TableRelation = "Alfa License";
            ValidateTableRelation = True;
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(3; "Company Name"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Company Name';
            TableRelation = Company;
            ValidateTableRelation = True;
        }
        field(4; "Created Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Company Name';
        }
    }

    keys
    {
        key(PK; "Product Id", "line No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}