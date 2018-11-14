page 70140953 "Alfa Data Migration Wizard"
{
    // version NAVW113.00

    ApplicationArea = All;
    Caption = 'Alfa Data Migration';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = NavigatePage;
    ShowFilter = false;
    SourceTable = "Alfa DataMigrator Registration";
    SourceTableTemporary = true;
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            group(StandardBanner)
            {
                Editable = false;
                Visible = TopBannerVisible AND NOT DoneVisible;
            }
            group(FinishedBanner)
            {
                Editable = false;
                Visible = TopBannerVisible AND DoneVisible;
            }
            group(Step3)
            {
                Visible = IntroVisible;
                group("Welcome to Data Migration assisted setup guide")
                {
                    Caption = 'Welcome to Data Migration assisted setup guide';
                    InstructionalText = 'You can import data from other finance solutions and other data sources, provided that the corresponding extension is available to handle the conversion. To see a list of available extensions, choose the Open Extension Management button.';
                }
                group("Let's go!")
                {
                    Caption = 'Let''s go!';
                    InstructionalText = 'Choose Next to choose your data source.';
                }
            }
            group(Step4)
            {
                Visible = ChooseSourceVisible;
                group("Choose your data source")
                {
                    Caption = 'Choose your data source';
                    InstructionalText = 'Which finance app do you want to migrate data from?';
                    field(Description; Description)
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        TableRelation = "Data Migrator Registration".Description;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            IF PAGE.RUNMODAL(PAGE::"Data Migrators", Rec) = ACTION::LookupOK THEN BEGIN
                                Text := Description;
                                CLEAR(DataMigrationSettingsVisible);
                                OnHasSettingsAlfa(DataMigrationSettingsVisible);
                                EXIT;
                            END;
                        end;
                    }
                }
            }
            group(Step5)
            {
                Visible = ImportVisible;
                group(InstructionsGroup)
                {
                    Caption = 'Instructions';
                    InstructionalText = 'To prepare the data for migration, follow these steps:';
                    Visible = Instructions <> '';
                    field(Instructions; Instructions)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                }
                group(Settings)
                {
                    Caption = 'Settings';
                    InstructionalText = 'You can change the import settings for this data source by choosing Settings in the actions below.';
                    Visible = DataMigrationSettingsVisible;
                }
            }
            group(Step6)
            {
                Visible = ApplyVisible;
                part(DataMigrationEntities; 1810)
                {
                    ApplicationArea = All;
                    Caption = 'Data is ready for migration';
                }
                group(Step61)
                {
                    Visible = ShowPostingOptions;
                    grid(Grid1)
                    {
                        GridLayout = Columns;
                        field(BallancesPostingOption; BallancesPostingOption)
                        {
                            ApplicationArea = All;
                            Caption = 'Opening balances';
                            ShowMandatory = true;
                            ToolTip = 'Specifies what to do with opening balances. We can post them for you, or you can review balances in journals and post them yourself.';

                            trigger OnValidate()
                            begin
                                SetPosting;
                            end;
                        }
                        group(Step62)
                        {
                            Visible = BallancesPostingOption = BallancesPostingOption::"Post balances for me";
                            field(PostingDate; PostingDate)
                            {
                                ApplicationArea = All;
                                Caption = 'Post to ledger on';
                                ToolTip = 'Specifies the date to post the journal on.';

                                trigger OnValidate()
                                begin
                                    SetPosting;
                                end;
                            }
                        }
                    }
                }
            }
            group("POSTING GROUP SETUP")
            {
                Caption = 'POSTING GROUP SETUP';
                Visible = PostingGroupIntroVisible;
                group("Welcome to Posting Group Setup")
                {
                    Caption = 'Welcome to Posting Group Setup';
                    InstructionalText = 'For posting accounts, you can specify the general ledger accounts that you want to post sales and purchase transactions to.';
                }
                group("Let's go")
                {
                    Caption = 'Let''s go!';
                    InstructionalText = 'Choose Next to create posting accounts for purchasing and sales transactions.';
                }
            }
            group(Step7)
            {
                InstructionalText = 'Select the accounts to use when posting.';
                Visible = FirstAccountSetupVisible;
                field("Sales Account"; SalesAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Account';
                    TableRelation = "G/L Account"."No.";
                }
                field("Sales Credit Memo Account"; SalesCreditMemoAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Credit Memo Account';
                    TableRelation = "G/L Account"."No.";
                }
                field("Sales Line Disc. Account"; SalesLineDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Line Disc. Account';
                    TableRelation = "G/L Account"."No.";
                }
                field("Sales Inv. Disc. Account"; SalesInvDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Sales Inv. Disc. Account';
                    TableRelation = "G/L Account"."No.";
                }
                field("."; '')
                {
                    ApplicationArea = All;
                    Editable = false;
                    HideValue = true;
                    ShowCaption = false;
                }
                field("Purch. Account"; PurchAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Account';
                    TableRelation = "G/L Account"."No.";
                }
                field("Purch. Credit Memo Account"; PurchCreditMemoAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Credit Memo Account';
                    TableRelation = "G/L Account"."No.";
                }
                field("Purch. Line Disc. Account"; PurchLineDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Line Disc. Account';
                    TableRelation = "G/L Account"."No.";
                }
                field("Purch. Inv. Disc. Account"; PurchInvDiscAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Inv. Disc. Account';
                    TableRelation = "G/L Account"."No.";
                }
                field(".."; '')
                {
                    ApplicationArea = All;
                    Editable = false;
                    HideValue = true;
                    ShowCaption = false;
                }
                group(Step71)
                {
                    InstructionalText = 'When importing items, the following accounts need to be entered';
                    Visible = FirstAccountSetupVisible;
                }
                field("COGS Account"; COGSAccount)
                {
                    ApplicationArea = All;
                    Caption = 'COGS Account';
                    TableRelation = "G/L Account"."No.";
                }
                field("Inventory Adjmt. Account"; InventoryAdjmtAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Adjmt. Account';
                    TableRelation = "G/L Account"."No.";
                }
                field("Inventory Account"; InventoryAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Account';
                    TableRelation = "G/L Account"."No.";
                }
            }
            group(Step8)
            {
                InstructionalText = 'Select the accounts to use when posting.';
                Visible = SecondAccountSetupVisible;
                group(Step81)
                {
                    InstructionalText = 'Customers';
                }
                field("Receivables Account"; ReceivablesAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Receivables Account';
                    TableRelation = "G/L Account"."No.";
                }
                field("Service Charge Acc."; ServiceChargeAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Service Charge Acc.';
                    TableRelation = "G/L Account"."No.";
                }
                group(Step82)
                {
                    InstructionalText = 'Vendors';
                }
                field("Payables Account"; PayablesAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Payables Account';
                    TableRelation = "G/L Account"."No.";
                }
                field("Purch. Service Charge Acc."; PurchServiceChargeAccount)
                {
                    ApplicationArea = All;
                    Caption = 'Purch. Service Charge Acc.';
                    TableRelation = "G/L Account"."No.";
                }
            }
            group(Step9)
            {
                Visible = DoneVisible;
                group("That's it!")
                {
                    Caption = 'That''s it!';
                    InstructionalText = 'You have completed the Data Migration assisted setup guide.';
                    Visible = NOT ShowErrorsVisible;
                }
                group(Step91)
                {
                    Visible = ThatsItText <> '';
                    field(ThatsItText; ThatsItText)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        MultiLine = true;
                        ShowCaption = false;
                    }
                    group(Step92)
                    {
                        Visible = EnableTogglingOverviewPage;
                        field(ShowOverviewPage; ShowOverviewPage)
                        {
                            ApplicationArea = All;
                            Caption = 'View the status when finished';
                            ShowCaption = true;
                        }
                    }
                }
                group("Duplicate contacts?")
                {
                    Caption = 'Duplicate contacts?';
                    InstructionalText = 'We found some contacts that were duplicated. You can review the list, and decide what to do with them.';
                    Visible = ShowDuplicateContactsText;
                    field(DuplicateContacts; DuplicateContactsLbl)
                    {
                        ApplicationArea = All;
                        Editable = false;
                        ShowCaption = false;

                        trigger OnDrillDown()
                        begin
                            PAGE.RUN(PAGE::"Contact Duplicates");
                        end;
                    }
                }
                group("Import completed with errors")
                {
                    Caption = 'Import completed with errors';
                    InstructionalText = 'There were errors during import of your data. For more details, choose Show Errors in the actions below.';
                    Visible = ShowErrorsVisible;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ActionOpenExtensionManagement)
            {
                ApplicationArea = All;
                Caption = 'Open Extension Management';
                Image = Setup;
                InFooterBar = true;
                RunObject = Page "Extension Management";
                Visible = Step = Step::Intro;
            }
            action(ActionDownloadTemplate)
            {
                ApplicationArea = All;
                Caption = 'Download Template';
                Image = "Table";
                InFooterBar = true;
                Visible = DownloadTemplateVisible AND (Step = Step::Import);

                trigger OnAction()
                var
                    Handled: Boolean;
                begin
                    OnDownloadTemplateAlfa(Handled);
                    IF NOT Handled THEN
                        ERROR('');
                end;
            }
            action(ActionDataMigrationSettings)
            {
                ApplicationArea = All;
                Caption = 'Settings';
                Image = Setup;
                InFooterBar = true;
                Visible = DataMigrationSettingsVisible AND (Step = Step::Import);

                trigger OnAction()
                var
                    Handled: Boolean;
                begin
                    OnOpenSettingsAlfa(Handled);
                    IF NOT Handled THEN
                        ERROR('');
                end;
            }
            action(ActionOpenAdvancedApply)
            {
                ApplicationArea = All;
                Caption = 'Advanced';
                Image = Apply;
                InFooterBar = true;
                Visible = OpenAdvancedApplyVisible AND (Step = Step::Apply);

                trigger OnAction()
                var
                    Handled: Boolean;
                begin
                    OnOpenAdvancedApplyAlfa(TempDataMigrationEntity, Handled);
                    CurrPage.DataMigrationEntities.PAGE.CopyToSourceTable(TempDataMigrationEntity);
                    IF NOT Handled THEN
                        ERROR('');
                end;
            }
            action(ActionShowErrors)
            {
                ApplicationArea = All;
                Caption = 'Show Errors';
                Image = ErrorLog;
                InFooterBar = true;
                Visible = ShowErrorsVisible AND ((Step = Step::Done) OR (Step = Step::ShowPostingGroupDoneStep));

                trigger OnAction()
                var
                    Handled: Boolean;
                begin
                    OnShowErrorsAlfa(Handled);
                    IF NOT Handled THEN
                        ERROR('');
                end;
            }
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = BackEnabled;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    CASE Step OF
                        Step::Apply:
                            TempDataMigrationEntity.DELETEALL;
                    END;
                    NextStep(TRUE);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = NextEnabled;
                Image = NextRecord;
                InFooterBar = true;
                Visible = NOT ApplyButtonVisible;

                trigger OnAction()
                begin
                    NextAction;
                end;
            }
            action(ActionApply)
            {
                ApplicationArea = All;
                Caption = 'Migrate';
                Enabled = ApplyButtonEnabled;
                Image = NextRecord;
                InFooterBar = true;
                Visible = ApplyButtonVisible;

                trigger OnAction()
                begin
                    NextAction;
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = FinishEnabled;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                var
                    AssistedSetup: Record "Assisted Setup";
                begin
                    AssistedSetup.SetStatus(PAGE::"Data Migration Wizard", AssistedSetup.Status::Completed);
                    CurrPage.CLOSE;
                    IF ShowOverviewPage THEN
                        PAGE.RUN(PAGE::"Data Migration Overview");
                end;
            }
        }
    }

    trigger OnInit()
    begin
        LoadTopBanners;
    end;

    trigger OnOpenPage()
    var
        DataMigrationMgt: Codeunit "Data Migration Mgt.";
    begin
        OnRegisterDataMigratorAlfa;
        IF FINDFIRST THEN;
        ResetWizardControls;
        ShowIntroStep;
        DataMigrationMgt.CheckMigrationInProgress(FALSE);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        AssistedSetup: Record "Assisted Setup";
    begin
        IF CloseAction = ACTION::OK THEN
            IF AssistedSetup.GetStatus(PAGE::"Data Migration Wizard") = AssistedSetup.Status::"Not Completed" THEN
                IF NOT CONFIRM(DataImportNotCompletedQst, FALSE) THEN
                    ERROR('');
    end;

    var
        TempDataMigrationEntity: Record "Data Migration Entity" temporary;
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        ClientTypeManagement: Codeunit "ClientTypeManagement";
        Step: Option Intro,ChooseSource,Import,Apply,Done,PostingGroupIntro,AccountSetup1,AccountSetup2,ShowPostingGroupDoneStep;
        BallancesPostingOption: Option " ","Post balances for me","Review balances first";
        BackEnabled: Boolean;
        NextEnabled: Boolean;
        ApplyButtonVisible: Boolean;
        ApplyButtonEnabled: Boolean;
        FinishEnabled: Boolean;
        TopBannerVisible: Boolean;
        IntroVisible: Boolean;
        ChooseSourceVisible: Boolean;
        ImportVisible: Boolean;
        ApplyVisible: Boolean;
        DoneVisible: Boolean;
        DataImportNotCompletedQst: Label 'Data Migration has not been completed.\\Are you sure that you want to exit?';
        DownloadTemplateVisible: Boolean;
        DataMigrationSettingsVisible: Boolean;
        OpenAdvancedApplyVisible: Boolean;
        ShowErrorsVisible: Boolean;
        PostingGroupIntroVisible: Boolean;
        FirstAccountSetupVisible: Boolean;
        SecondAccountSetupVisible: Boolean;
        AccountSetupVisible: Boolean;
        ShowPostingOptions: Boolean;
        ShowDuplicateContactsText: Boolean;
        Instructions: Text;
        ThatsItText: Text;
        TotalNoOfMigrationRecords: Integer;
        SalesAccount: Code[20];
        SalesCreditMemoAccount: Code[20];
        SalesLineDiscAccount: Code[20];
        SalesInvDiscAccount: Code[20];
        PurchAccount: Code[20];
        PurchCreditMemoAccount: Code[20];
        PurchLineDiscAccount: Code[20];
        PurchInvDiscAccount: Code[20];
        COGSAccount: Code[20];
        InventoryAdjmtAccount: Code[20];
        InventoryAccount: Code[20];
        ReceivablesAccount: Code[20];
        ServiceChargeAccount: Code[20];
        PayablesAccount: Code[20];
        PurchServiceChargeAccount: Code[20];
        PostingDate: Date;
        DuplicateContactsLbl: Label 'Review duplicate contacts';
        BallancesPostingErr: Label 'We need to know what to do with opening balances. You can:\\Let us post opening balances to the general ledger and item ledger for you, on a date you choose\\Review opening balances in journals first, and then post them yourself.';
        MissingAccountingPeriodeErr: Label 'Posting date %1 is not within an open accounting period. To see open periods, go to the Accounting Periods page.', Comment = '% = Posting Date';
        EnableTogglingOverviewPage: Boolean;
        ShowOverviewPage: Boolean;

    local procedure NextAction()
    var
        Handled: Boolean;
        ShowBalance: Boolean;
        HideSelected: Boolean;
        ListOfAccounts: array[11] of Code[20];
    begin
        CASE Step OF
            Step::ChooseSource:
                BEGIN
                    OnGetInstructionsAlfa(Instructions, Handled);
                    IF NOT Handled THEN
                        ERROR('');
                END;
            Step::Import:
                BEGIN
                    OnShowBalanceAlfa(ShowBalance);
                    OnHideSelectedAlfa(HideSelected);
                    CurrPage.DataMigrationEntities.PAGE.SetShowBalance(ShowBalance);
                    CurrPage.DataMigrationEntities.PAGE.SetHideSelected(HideSelected);
                    OnValidateSettingsAlfa;
                    OnDataImportAlfa(Handled);
                    IF NOT Handled THEN
                        ERROR('');
                    OnSelectDataToApplyAlfa(TempDataMigrationEntity, Handled);
                    CurrPage.DataMigrationEntities.PAGE.CopyToSourceTable(TempDataMigrationEntity);
                    TotalNoOfMigrationRecords := GetTotalNoOfMigrationRecords(TempDataMigrationEntity);
                    IF NOT Handled THEN
                        ERROR('');
                END;
            Step::Apply:
                BEGIN
                    IF ShowPostingOptions THEN
                        IF BallancesPostingOption = BallancesPostingOption::" " THEN
                            ERROR(BallancesPostingErr);
                    CurrPage.DataMigrationEntities.PAGE.CopyFromSourceTable(TempDataMigrationEntity);
                    OnApplySelectedDataAlfa(TempDataMigrationEntity, Handled);
                    IF NOT Handled THEN
                        ERROR('');
                END;
            Step::AccountSetup1:
                BEGIN
                    ListOfAccounts[1] := SalesAccount;
                    ListOfAccounts[2] := SalesCreditMemoAccount;
                    ListOfAccounts[3] := SalesLineDiscAccount;
                    ListOfAccounts[4] := SalesInvDiscAccount;
                    ListOfAccounts[5] := PurchAccount;
                    ListOfAccounts[6] := PurchCreditMemoAccount;
                    ListOfAccounts[7] := PurchLineDiscAccount;
                    ListOfAccounts[8] := PurchInvDiscAccount;
                    ListOfAccounts[9] := COGSAccount;
                    ListOfAccounts[10] := InventoryAdjmtAccount;
                    ListOfAccounts[11] := InventoryAccount;
                    OnGLPostingSetupAlfa(ListOfAccounts);
                END;
            Step::AccountSetup2:
                BEGIN
                    ListOfAccounts[1] := ReceivablesAccount;
                    ListOfAccounts[2] := ServiceChargeAccount;
                    ListOfAccounts[3] := PayablesAccount;
                    ListOfAccounts[4] := PurchServiceChargeAccount;
                    OnCustomerVendorPostingSetupAlfa(ListOfAccounts);
                END;
        END;
        NextStep(FALSE);
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        ResetWizardControls;

        IF Backwards THEN
            Step := Step - 1
        ELSE
            Step := Step + 1;

        CASE Step OF
            Step::Intro:
                ShowIntroStep;
            Step::ChooseSource:
                ShowChooseSourceStep;
            Step::Import:
                ShowImportStep;
            Step::Apply:
                ShowApplyStep;
            Step::Done:
                ShowDoneStep;
            Step::PostingGroupIntro:
                ShowPostingGroupIntroStep;
            Step::AccountSetup1:
                ShowFirstAccountStep;
            Step::AccountSetup2:
                ShowSecondAccountStep;
            Step::ShowPostingGroupDoneStep:
                ShowPostingGroupDoneStep;
        END;
        CurrPage.UPDATE(TRUE);
    end;

    local procedure ShowIntroStep()
    begin
        IntroVisible := TRUE;
        BackEnabled := FALSE;
        PostingGroupIntroVisible := FALSE;
    end;

    local procedure ShowChooseSourceStep()
    begin
        ChooseSourceVisible := TRUE;
    end;

    local procedure ShowImportStep()
    begin
        ImportVisible := TRUE;
        OnHasTemplateAlfa(DownloadTemplateVisible);
        OnHasSettingsAlfa(DataMigrationSettingsVisible);
    end;

    local procedure ShowApplyStep()
    begin
        ApplyVisible := TRUE;
        ShowPostingOptions := FALSE;
        NextEnabled := FALSE;
        ApplyButtonVisible := TRUE;
        ApplyButtonEnabled := TotalNoOfMigrationRecords > 0;
        OnHasAdvancedApplyAlfa(OpenAdvancedApplyVisible);
        OnShowPostingOptionsAlfa(ShowPostingOptions);
        IF ShowPostingOptions THEN BEGIN
            PostingDate := WORKDATE;
            CurrPage.DataMigrationEntities.PAGE.SetPostingInfromation(
              BallancesPostingOption = BallancesPostingOption::"Post balances for me", PostingDate);
        END;
    end;

    local procedure ShowDoneStep()
    begin
        DoneVisible := TRUE;
        NextEnabled := FALSE;
        FinishEnabled := TRUE;
        BackEnabled := FALSE;
        OnPostingGroupSetupAlfa(AccountSetupVisible);
        IF AccountSetupVisible THEN BEGIN
            TempDataMigrationEntity.RESET;
            TempDataMigrationEntity.SETRANGE("Table ID", 15);
            TempDataMigrationEntity.SETRANGE(Selected, TRUE);
            IF TempDataMigrationEntity.FINDFIRST THEN BEGIN
                DoneVisible := FALSE;
                NextEnabled := TRUE;
                FinishEnabled := FALSE;
                NextStep(FALSE);
            END;
        END;
        OnHasErrorsAlfa(ShowErrorsVisible);
        OnShowDuplicateContactsTextAlfa(ShowDuplicateContactsText);
        OnShowThatsItMessageAlfa(ThatsItText);

        OnEnableTogglingDataMigrationOverviewPageAlfa(EnableTogglingOverviewPage);
        IF EnableTogglingOverviewPage THEN
            ShowOverviewPage := TRUE;
    end;

    local procedure ShowPostingGroupIntroStep()
    begin
        DoneVisible := FALSE;
        BackEnabled := FALSE;
        NextEnabled := TRUE;
        PostingGroupIntroVisible := TRUE;
        FirstAccountSetupVisible := FALSE;
        SecondAccountSetupVisible := FALSE;
        FinishEnabled := FALSE;
    end;

    local procedure ShowFirstAccountStep()
    begin
        DoneVisible := FALSE;
        BackEnabled := FALSE;
        NextEnabled := TRUE;
        FirstAccountSetupVisible := TRUE;
        SecondAccountSetupVisible := FALSE;
        PostingGroupIntroVisible := FALSE;
        FinishEnabled := FALSE;
    end;

    local procedure ShowSecondAccountStep()
    begin
        DoneVisible := FALSE;
        BackEnabled := TRUE;
        NextEnabled := TRUE;
        PostingGroupIntroVisible := FALSE;
        FirstAccountSetupVisible := FALSE;
        SecondAccountSetupVisible := TRUE;
        FinishEnabled := FALSE;
    end;

    local procedure ResetWizardControls()
    begin
        // Buttons
        BackEnabled := TRUE;
        NextEnabled := TRUE;
        ApplyButtonVisible := FALSE;
        ApplyButtonEnabled := FALSE;
        FinishEnabled := FALSE;
        DownloadTemplateVisible := FALSE;
        DataMigrationSettingsVisible := FALSE;
        OpenAdvancedApplyVisible := FALSE;
        ShowErrorsVisible := FALSE;
        PostingGroupIntroVisible := FALSE;
        FirstAccountSetupVisible := FALSE;
        SecondAccountSetupVisible := FALSE;

        // Tabs
        IntroVisible := FALSE;
        ChooseSourceVisible := FALSE;
        ImportVisible := FALSE;
        ApplyVisible := FALSE;
        DoneVisible := FALSE;
    end;

    local procedure GetTotalNoOfMigrationRecords(var DataMigrationEntity: Record "Data Migration Entity") TotalCount: Integer
    begin
        IF DataMigrationEntity.FINDSET THEN
            REPEAT
                TotalCount += DataMigrationEntity."No. of Records";
            UNTIL DataMigrationEntity.NEXT = 0;
    end;

    local procedure LoadTopBanners()
    begin
        IF MediaRepositoryStandard.GET('AssistedSetup-NoText-400px.png', FORMAT(ClientTypeManagement.GetCurrentClientType)) AND
           MediaRepositoryDone.GET('AssistedSetupDone-NoText-400px.png', FORMAT(ClientTypeManagement.GetCurrentClientType))
        THEN
            IF MediaResourcesStandard.GET(MediaRepositoryStandard."Media Resources Ref") AND
               MediaResourcesDone.GET(MediaRepositoryDone."Media Resources Ref")
            THEN
                TopBannerVisible := MediaResourcesDone."Media Reference".HASVALUE;
    end;

    local procedure ShowPostingGroupDoneStep()
    begin
        DoneVisible := TRUE;
        BackEnabled := FALSE;
        NextEnabled := FALSE;
        OnHasErrorsAlfa(ShowErrorsVisible);
        FinishEnabled := TRUE;
    end;

    local procedure SetPosting()
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        IF BallancesPostingOption = BallancesPostingOption::"Post balances for me" THEN
            IF AccountingPeriod.GetFiscalYearStartDate(PostingDate) = 0D THEN
                ERROR(MissingAccountingPeriodeErr, PostingDate);

        CurrPage.DataMigrationEntities.PAGE.SetPostingInfromation(
          BallancesPostingOption = BallancesPostingOption::"Post balances for me", PostingDate);
    end;
}

