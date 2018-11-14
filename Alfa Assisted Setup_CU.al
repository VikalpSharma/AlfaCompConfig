codeunit 70140951 "Alfa Assisted Setup"
{

    [EventSubscriber(ObjectType::Table, Database::"Aggregated Assisted Setup", 'OnRegisterAssistedSetup', '', true, true)]
    local procedure AlfaOnRegisterAssistedSetup(var TempAggregatedAssistedSetup: Record "Aggregated Assisted Setup")
    var
        AlfaConfigSetup: Record "Alfa Config. Setup";
        AssistedSetup: Record "Assisted Setup";
        lStatus: Integer;
    begin
        IF AssistedSetup.Get(Page::"Alfa Company Setup Wizard") THEN
            lStatus := AssistedSetup.GetStatus(Page::"Alfa Company Setup Wizard")
        ELse
            lStatus := 0;
        TempAggregatedAssistedSetup.AddExtensionAssistedSetup(
                                    Page::"Alfa Company Setup Wizard"
                                    , 'Alfa Company Setup'
                                    , true
                                    , AlfaConfigSetup.RecordId()
                                    , lStatus
                                    , '');
        IF AssistedSetup.Get(Page::"Alfa Data Migration Wizard") THEN
            lStatus := AssistedSetup.GetStatus(Page::"Alfa Data Migration Wizard")
        ELse
            lStatus := 0;
        TempAggregatedAssistedSetup.AddExtensionAssistedSetup(
                                    Page::"Alfa Data Migration Wizard"
                                    , 'Alfa Data Migration'
                                    , true
                                    , AlfaConfigSetup.RecordId()
                                    , lStatus
                                    , '');
    end;

    local procedure GetCompanyInformationSetupStatus(AggregatedAssistedSetup: Record "Aggregated Assisted Setup"): Integer
    var
        AlfaConfigSetup: Record "Alfa Config. Setup";
        Companyinfo: Record "Company Information";

        Reccount: Integer;
    begin
        with AggregatedAssistedSetup do begin
            IF (Companyinfo.get()) AND (Companyinfo.Name <> '') then
                Status := Status::Completed
            else
                Status := Status::"Not Completed";
            exit(Status);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', true, true)]
    Local Procedure CreateAssistedSetupCompConfig()
    var
        AssistedSetup: Record "Assisted Setup";
        NewOrderNumber: integer;
    Begin
        IF AssistedSetup.GET(PAGE::"Alfa Company Setup Wizard") THEN
            EXIT;

        AssistedSetup.LOCKTABLE;
        AssistedSetup.SETCURRENTKEY(Order, Visible);
        IF AssistedSetup.FINDLAST THEN
            NewOrderNumber := AssistedSetup.Order + 1
        ELSE
            NewOrderNumber := 1;

        CLEAR(AssistedSetup);
        AssistedSetup.INIT;
        AssistedSetup.VALIDATE("Page ID", Page::"Alfa Company Setup Wizard");
        AssistedSetup.VALIDATE(Name, 'Alfa Comapny Setup');
        AssistedSetup.VALIDATE(Order, NewOrderNumber);
        AssistedSetup.VALIDATE(Status, AssistedSetup.Status::"Not Completed");
        AssistedSetup.VALIDATE(Visible, TRUE);
        AssistedSetup."Assisted Setup Page ID" := Page::"Alfa Company Setup Wizard";
        AssistedSetup.INSERT(TRUE);
    End;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', true, true)]
    Local Procedure CreateAssistedSetupDataMigrator()
    var
        AssistedSetup: Record "Assisted Setup";
        NewOrderNumber: integer;
    Begin
        IF AssistedSetup.GET(PAGE::"Alfa Data Migration Wizard") THEN
            EXIT;

        AssistedSetup.SETCURRENTKEY(Order, Visible);
        AssistedSetup.LOCKTABLE;
        IF AssistedSetup.FINDLAST THEN
            NewOrderNumber := AssistedSetup.Order + 1
        ELSE
            NewOrderNumber := 1;

        CLEAR(AssistedSetup);
        AssistedSetup.INIT;
        AssistedSetup.VALIDATE("Page ID", Page::"Alfa Data Migration Wizard");
        AssistedSetup.VALIDATE(Name, 'Alfa Data Migration');
        AssistedSetup.VALIDATE(Order, NewOrderNumber);
        AssistedSetup.VALIDATE(Status, AssistedSetup.Status::"Not Completed");
        AssistedSetup.VALIDATE(Visible, TRUE);
        AssistedSetup."Assisted Setup Page ID" := Page::"Alfa Data Migration Wizard";
        AssistedSetup.INSERT(TRUE);
    End;

    [EventSubscriber(ObjectType::Codeunit, codeunit::LogInManagement, 'OnAfterCompanyOpen', '', true, true)]
    local procedure AlfaAssistedCompanySetup()
    var
        AssistedSetup: Record "Assisted Setup";
        IdentityManagement: Codeunit "Identity Management";
    begin
        IF NOT GUIALLOWED THEN
            EXIT;

        IF IdentityManagement.IsInvAppId THEN
            EXIT; // Invoicing handles company setup silently

        IF NOT AssistedSetup.READPERMISSION THEN
            EXIT;

        IF CompanyActive THEN
            EXIT;

        IF NOT AssistedSetupEnabled THEN
            EXIT;

        IF NOT AssistedSetup.GET(PAGE::"Alfa Company Setup Wizard") THEN
            EXIT;

        IF AssistedSetup.Status = AssistedSetup.Status::Completed THEN
            EXIT;

        COMMIT; // Make sure all data is committed before we run the wizard

        AssistedSetup.Run;
    end;

    local procedure CompanyActive(): Boolean
    var
        GLEntry: Record "G/L Entry";
    begin
        IF NOT GLEntry.READPERMISSION THEN
            EXIT(TRUE);

        EXIT(NOT GLEntry.ISEMPTY);
    end;

    local procedure AssistedSetupEnabled(): Boolean
    var
        AssistedCompanySetupStatus: Record "Assisted Company Setup Status";
    begin
        EXIT(AssistedCompanySetupStatus.GET(COMPANYNAME) AND AssistedCompanySetupStatus.Enabled);
    end;
}