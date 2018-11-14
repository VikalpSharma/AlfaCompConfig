page 70140951 "Alfa Company Setup Wizard"
{
    PageType = NavigatePage;
    //PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Alfa Config. Setup";
    Caption = 'Company Setup Wizard';

    layout
    {
        area(Content)
        {
            group(StandardBanner)
            {
                Editable = false;
                Visible = TopBannerVisible and (CurrentStep < 5);
            }
            group(FinishedBanner)
            {
                Editable = False;
                Visible = TopBannerVisible and (CurrentStep = 5);
            }
            group(Step1)
            {
                Visible = (CurrentStep = 1);

                group(Welcome)
                {
                    Caption = 'Welcome to the wizard creating company and configuration.';
                    InstructionalText = 'This guide will help you creating new company, setup finance and inventory module as per selection.';
                    group(Letsgo)
                    {
                        Caption = 'Lets Go';
                        InstructionalText = 'Choose Next to get started.';
                    }

                }
            }
            group(Step2)
            {
                Visible = (CurrentStep = 2);
                Caption = 'Select module';
                group("Enter License Key")
                {
                    field(CustomerName; CustomerName)
                    {
                        ApplicationArea = All;
                        Caption = 'Customer Name';
                        ToolTip = 'Enter Customer Name';
                    }
                    field(LicenseKey; LicenseKey)
                    {
                        ApplicationArea = All;
                        Caption = 'License Key';
                        ToolTip = 'Enter license key';
                    }

                }
            }
            group(Step3)
            {
                Visible = (CurrentStep = 3);
                group("Enter comapny complete information")
                {
                    group("Enter basic info")
                    {
                        Caption = 'Enter Basic Info';
                        field(Name; Name)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the name of your company that you are configuring.';
                        }
                        field(Address; Address)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies an address for the company that you are configuring.';
                        }
                        field("Address 2"; "Address 2")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies additional address information.';
                        }
                        field("Post Code"; "Post Code")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the postal code.';
                        }
                        field(City; City)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the city where the company that you are configuring is located.';
                        }
                        field("Country/Region Code"; "Country/Region Code")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the country/region of the address.';
                        }
                        field("VAT Registration No."; "VAT Registration No.")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the VAT registration number.';
                        }
                        field("Industrial Classification"; "Industrial Classification")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the type of industry that the company that you are configuring is.';
                        }
                        field(Picture; Picture)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the picture that has been set up for the company, for example, a company logo.';
                        }

                    }
                    group("Enter communication info")
                    {
                        field("Phone No."; "Phone No.")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the telephone number of the company that you are configuring.';
                        }
                        field("Fax No."; "Fax No.")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies fax number of the company that you are configuring.';
                        }
                        field("E-Mail"; "E-Mail")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the email address of the company that you are configuring.';
                        }
                        field("Home Page"; "Home Page")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies your company web site.';
                        }
                    }
                    group("Enter payment info")
                    {
                        field("Bank Name"; "Bank Name")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the name of the bank the company uses.';
                        }
                        field("Bank Branch No."; "Bank Branch No.")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the branch number of the bank that the company that you are configuring uses.';
                        }
                        field("Bank Account No."; "Bank Account No.")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the bank account number of the company that you are configuring.';
                        }
                        field("Payment Routing No."; "Payment Routing No.")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the payment routing number of the company that you are configuring.';
                        }
                        field("Giro No."; "Giro No.")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the giro number of the company that you are configuring.';
                        }
                        field("SWIFT Code"; "SWIFT Code")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the SWIFT code (international bank identifier code) of the primary bank of the company that you are configuring.';
                        }
                        field(IBAN; IBAN)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies the international bank account number of the primary bank account of the company that you are configuring.';
                        }
                    }
                }
            }
            group(Step4)
            {
                Visible = (CurrentStep = 4);
                Caption = 'Select module';
                group("Select Modules")
                {
                    field("Finance Module"; "Finance Module")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Please select the module for finance module finance related setup';
                    }
                    field("Inventory Module"; "Inventory Module")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Please select for inventory module for inventory setup';
                    }
                }
            }
            group(Step5)
            {
                Caption = 'Select Package.';
                Visible = (CurrentStep = 5);
                group(Control1)
                {
                    ShowCaption = false;
                    field(PackageFileNameRtc; PackageFileName)
                    {
                        ApplicationArea = All;
                        Caption = 'Select the configuration package you want to load:';
                        Editable = false;
                        ToolTip = 'Specifies the name of the configuration package that you have created.';
                        AssistEdit = true;

                        trigger OnAssistEdit()
                        var
                            FileManagement: Codeunit "File Management";
                            ConfigXMLExchange: Codeunit "Config. XML Exchange";
                        begin
                            if ConfigVisible then
                                Error(PackageIsAlreadyAppliedErr);

                            "Package File Name" :=
                              CopyStr(
                                FileManagement.OpenFileDialog(
                                  Text004, '', ConfigXMLExchange.GetFileDialogFilter), 1, MaxStrLen("Package File Name"));

                            if "Package File Name" <> '' then begin
                                Validate("Package File Name");
                                ApplyVisible := true;
                            end else
                                ApplyVisible := false;
                            PackageFileName := FileManagement.GetFileName("Package File Name");
                        end;

                        trigger OnValidate()
                        begin
                            if "Package File Name" = '' then
                                ApplyVisible := false;

                            CurrPage.Update;
                        end;
                    }
                    field("Package Code"; "Package Code")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the code of the configuration package.';
                    }
                    field("Package Name"; "Package Name")
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ToolTip = 'Specifies the name of the package that contains the configuration information.';
                    }
                    field("Choose Apply Package action to load the data from the configuration to Business Central tables."; '')
                    {
                        ApplicationArea = All;
                        Caption = 'Choose Apply Package action to load the data from the configuration to Business Central tables.';
                        ToolTip = 'Specifies the action that loads the configuration data.';
                    }
                    field("Choose Configuration Worksheet if you want to edit and modify applied data."; '')
                    {
                        ApplicationArea = All;
                        Caption = 'Choose Configuration Worksheet if you want to edit and modify applied data.';
                        ToolTip = 'Specifies the action that loads the configuration data.';
                    }
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Apply Package")
            {
                ApplicationArea = All;
                Caption = 'Apply Package';
                Enabled = (currentstep = 5) and ApplyVisible;
                Image = Apply;
                InFooterBar = True;
                ToolTip = 'Import the configuration package and apply the package database data at the same time.';

                trigger OnAction()
                begin
                    if CompleteWizard then begin
                        ConfigVisible := true;
                        ActionFinishAllowed := true;
                    end else
                        Error(Text003);
                end;
            }
            /*action("Configuration Worksheet")
            {
                ApplicationArea = All;
                Caption = 'Configuration Worksheet';
                Enabled = (currentstep = 5) and ConfigVisible;
                InFooterBar = True;
                Image = SetupLines;
                RunObject = Page "Config. Worksheet";
                ToolTip = 'Plan and configure how to initialize a new solution based on legacy data and the customers requirements.';
            }*/
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                InFooterBar = true;
                Image = PreviousRecord;
                Enabled = ActionBackAllowed;

                trigger OnAction()
                begin
                    TakeStep(-1);
                end;
            }

            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                InFooterBar = true;
                Image = NextRecord;
                Enabled = ActionNextAllowed;

                trigger OnAction()
                var
                    AlfaLicense: Record "Alfa License";
                begin
                    IF CurrentStep = 2 THEN
                        IF AlfaLicense.CheckLicense(ProductId, LicenseKey) THEN
                            AlfaLicense.ImportLicense(ProductId, LicenseKey, CustomerName, ProductDesc);
                    If CurrentStep = 3 THEN
                        ValidateCompanyInfo();
                    TakeStep(1);
                end;
            }

            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                InFooterBar = true;
                Image = Approve;
                Enabled = ActionFinishAllowed;

                trigger OnAction()
                var
                    AlfaLicense: Record "Alfa License";
                begin
                    CurrPage.Close();
                    AssistedSetup.SetStatus(Page::"Alfa Company Setup Wizard", AssistedSetup.Status::Completed);
                    AlfaLicense.Get(ProductId);
                    AlfaLicense.Validate("No. of Legal Entity Remaining");
                    Commit();
                    AssistedSetup.Get(70140953);
                    AssistedSetup.run;
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        RESET;
        IF NOT GET THEN BEGIN
            INIT;
            INSERT;
        END ELSE begin
            DeleteAll();
            INIT;
            INSERT;
        END;
        GetCompanyInfo;
        CurrentStep := 1;
        SetControls();
    end;

    trigger OnInit()
    begin
        LoadTopBanners();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        IF CloseAction = ACTION::OK THEN
            IF AssistedSetup.GetStatus(PAGE::"Alfa Company Setup Wizard") = AssistedSetup.Status::"Not Completed" THEN
                IF NOT CONFIRM(NAVNotSetUpQst, FALSE) THEN
                    ERROR('');
    end;

    local procedure ValidateCompanyInfo()
    begin
        TestField(Name);
        TestField(Address);
        TestField("Post Code");
        TestField(City);
        TestField("Country/Region Code");
        TestField("VAT Registration No.");
        TestField("Phone No.");
    end;

    local procedure GetCompanyInfo()
    var
        Companyinfo: Record "Company Information";
    begin
        IF Companyinfo.Get then BEGIN
            Rec.TransferFields(Companyinfo);
            Rec.Modify();
        end;
    End;

    local procedure LoadTopBanners()
    begin
        if (MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType)) and
        MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType)))
        then
            if (MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
                MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref"))
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    local procedure SetControls()
    begin
        ActionBackAllowed := CurrentStep > 1;
        ActionNextAllowed := CurrentStep < 5;
        //ActionFinishAllowed := CurrentStep = 5;
    end;

    local procedure TakeStep(Step: Integer)
    begin
        CurrentStep += Step;
        SetControls();
    end;

    Var
        CurrentStep: Integer;
        ActionBackAllowed: Boolean;
        ActionNextAllowed: Boolean;
        ActionFinishAllowed: Boolean;
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        TopBannerVisible: Boolean;
        AssistedSetup: Record "Assisted Setup";
        NAVNotSetUpQst: Label 'Email has not been set up.\\Are you sure you want to exit?';
        Text004: Label 'Select a package file.';
        Text003: Label 'Select a package to run the Apply Package function.';
        ApplyVisible: Boolean;
        ConfigVisible: Boolean;
        PackageIsAlreadyAppliedErr: Label 'A package has already been selected and applied.';
        PackageFileName: Text;
        LicenseKey: Text[250];
        CustomerName: Text[100];
        ProductId: Label 'ALFA100002';
        ProductDesc: Label 'Company Configuration Wizard';

}