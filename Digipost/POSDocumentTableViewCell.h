//
// Copyright (C) Posten Norge AS
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//         http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIKit/UIKit.h>

@protocol SHCDocumentTableViewCellDelegate;

extern NSString *const kDocumentTableViewCellIdentifier;

@interface POSDocumentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIImageView *unreadImageView;
@property (weak, nonatomic) IBOutlet UIImageView *lockedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *attachmentImageView;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UIButton *editingButton;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *typeImage;



@property (nonatomic, assign) id<SHCDocumentTableViewCellDelegate> delegate;

- (IBAction)didTapEditingButton:(id)sender;

@end

@protocol SHCDocumentTableViewCellDelegate <NSObject>

- (void)documentTableViewCellDidTapEditingButton:(POSDocumentTableViewCell *)documentTableViewCell;

@end
