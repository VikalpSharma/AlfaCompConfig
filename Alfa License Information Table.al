
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
    }
    keys
    {
        key(PK; "Product ID")
        {
            Clustered = true;
        }
    }
    procedure CheckLicense(ProductId: Code[20]; LicenseKey: Text[250])
    var
        VoiceAccountNo: code[10];
        ExpiryDate: Date;
        NoOfLegalEntity: integer;
        LicenseInformation: Record "License Information";
        LicVoiceAccNo: Code[10];
    begin
        If LicenseKey = '' THEN
            Error('Please enter licensce key');
        DecryptLicenseKey(LicenseKey, VoiceAccountNo, ExpiryDate, NoOfLegalEntity);
        IF (ExpiryDate < Today()) THEN
            Error('License is Expired on %1', ExpiryDate);
        If (NoOfLegalEntity = 0) THEN
            Error('License is not valid for 0 legal entity');
        LicenseInformation.Reset();
        LicenseInformation.SetRange("Line No.", 4);
        IF LicenseInformation.FindFirst() THEN begin
            LicVoiceAccNo := CopyStr(LicenseInformation.Text, StrPos(LicenseInformation.Text, ':') + 2, 10);
            If LicVoiceAccNo <> VoiceAccountNo then
                Error('License is not valid for customer');
        END;

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
            AlfaLicenseInfo.Modify();
        END ELSE BEGIN
            AlfaLicenseInfo.Init();
            AlfaLicenseInfo."Product ID" := ProductID;
            AlfaLicenseInfo."License Key" := LicenseKey;
            AlfaLicenseInfo.Description := ProductDesc;
            AlfaLicenseInfo.Insert(True);
        END;
    End;
}