//
//  POSNewFolderViewController.m
//  Digipost
//
//  Created by Håkon Bogen on 26.05.14.
//  Copyright (c) 2014 Posten. All rights reserved.
//

#import "UIColor+Convenience.h"
#import "POSNewFolderViewController.h"
#import "POSFolderIcon.h"
#import "POSNewFolderCollectionViewCell.h"
#import <UIAlertView+Blocks.h>
#import "SHCAPIManager.h"
#import "POSNewFolderCollectionViewDataSource.h"
#import <MRProgress.h>

@interface POSNewFolderViewController () <UITextFieldDelegate>

@property (nonatomic, strong) POSNewFolderCollectionViewDataSource *dataSource;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
- (IBAction)saveButtonTapped:(id)sender;

@end

@implementation POSNewFolderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [[POSNewFolderCollectionViewDataSource alloc] initAsDataSourceForCollectionView:self.collectionView];
    self.collectionView.delegate = self;
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.textField setLeftViewMode:UITextFieldViewModeAlways];
    [self.textField setLeftView:spacerView];
    if (self.selectedFolder) {
        self.textField.text = self.selectedFolder.name;
        NSIndexPath *folderIconIndexPath = [self.dataSource indexPathForFolderIconWithName:self.selectedFolder.iconName];
        [self.collectionView selectItemAtIndexPath:folderIconIndexPath
                                          animated:NO
                                    scrollPosition:UICollectionViewScrollPositionTop];
        [self.textField becomeFirstResponder];
    } else {
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                      inSection:0]
                                          animated:NO
                                    scrollPosition:UICollectionViewScrollPositionTop];
        self.textField.delegate = self;
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    if ([self.collectionView.indexPathsForSelectedItems count] == 0) {
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    POSNewFolderCollectionViewCell *cell = (id)[collectionView cellForItemAtIndexPath : indexPath];
    POSFolderIcon *folderIcon = (id)[self.dataSource objectAtIndexPath : indexPath];
    cell.imageView.image = folderIcon.bigSelectedImage;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    POSNewFolderCollectionViewCell *cell = (id)[collectionView cellForItemAtIndexPath : indexPath];
    POSFolderIcon *folderIcon = (id)[self.dataSource objectAtIndexPath : indexPath];
    cell.imageView.image = folderIcon.bigImage;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)createNewFolder
{
    POSFolderIcon *selectedIcon = [self.dataSource objectAtIndexPath:self.collectionView.indexPathsForSelectedItems[0]];
    MRProgressOverlayView *overlayView = [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view
                                                                          animated:YES];
    [overlayView setTitleLabelText:@""];
    [[SHCAPIManager sharedManager] createFolderWithName:self.textField.text
        iconName:selectedIcon.name
        forMailBox:self.mailbox
        success:^{
                                                    [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
                                                    [self.navigationController popViewControllerAnimated:YES];
        }
        failure:^(NSError *error) {
                                                    [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
                                                    // TODO show error to user
                                                    if (error.code == -1011){
                                                        [UIAlertView showWithTitle:NSLocalizedString(@"Folder allready exists title", @"Title of the error telling user folder with the name allready exists") message:NSLocalizedString(@"Folder allready exists text", @"Text for error telling about folder with name exits") cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                            
                                                        }];
                                                    }else {
                                                        [UIAlertView showWithTitle:NSLocalizedString(@"Feil", @"Feil") message:NSLocalizedString(@"Noe feil skjedde.  ", @"Noe feil skjedde. ") cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                            
                                                        }];
                                                    }
        }];
}

- (void)changeFolder
{
    POSFolderIcon *selectedIcon = [self.dataSource objectAtIndexPath:self.collectionView.indexPathsForSelectedItems[0]];

    MRProgressOverlayView *overlayView = [MRProgressOverlayView showOverlayAddedTo:self.navigationController.view
                                                                          animated:YES];
    [overlayView setTitleLabelText:@""];
    [[SHCAPIManager sharedManager] changeFolder:self.selectedFolder
        newName:self.textField.text
        newIcon:selectedIcon.name
        success:^{
                                            [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
                                            [self.navigationController popViewControllerAnimated:YES];
        }
        failure:^(NSError *error) {
                                            [MRProgressOverlayView dismissOverlayForView:self.navigationController.view animated:YES];
                                            [UIAlertView showWithTitle:NSLocalizedString(@"Feil", @"Feil") message:NSLocalizedString(@"Noe feil skjedde.  ", @"Noe feil skjedde. ") cancelButtonTitle:NSLocalizedString(@"Ok", @"Ok") otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                
                                            }];
        }];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.text = @"";
    return YES;
}

- (IBAction)saveButtonTapped:(id)sender
{
    if (self.selectedFolder) {
        [self changeFolder];
    } else {
        [self createNewFolder];
    }
}
@end
