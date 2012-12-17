//
//  CLAboutViewController.m
//  Cloudy
//
//  Created by Parag Dulam on 11/12/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLAboutViewController.h"

@interface CLAboutViewController ()
{
    UIButton *cancelButton;
}

@end

@implementation CLAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    UIImage *baseImage = [UIImage imageNamed:@"button_background_base.png"];
    UIImage *buttonImage = [baseImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    [cancelButton setBackgroundImage:buttonImage
                           forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self
                    action:@selector(cancelButtonTapped:)
          forControlEvents:UIControlEventTouchUpInside];
    [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.f]];
    [cancelButton setFrame:CGRectMake(0, 0, 60, 30)];
    UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    [self.navigationItem setRightBarButtonItem:cancelBarButtonItem];
    [cancelBarButtonItem release];
    
    //Setting Up About Button End
    [tableDataArray addObject:@"Contact the Developer"];
    [self.navigationItem setTitle:@"About"];
    [self updateView];
}


-(void) cancelButtonTapped:(UIButton *) btn
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView
                       cellForRowAtIndexPath:indexPath];
    [cell.textLabel setText:[tableDataArray objectAtIndex:indexPath.row]];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    [controller setMailComposeDelegate:self];
    [controller setToRecipients:[NSArray arrayWithObject:@"paragdulam@gmail.com"]];
    [controller setSubject:@"Help me with this"];
    if ([MFMailComposeViewController canSendMail]) {
        [self presentModalViewController:controller animated:YES];
    } else {
        [AppDelegate showMessage:@"Please Configure your Mail"
                       withColor:[UIColor redColor]
                     alertOnView:self.view];
    }
    [controller release];
}


#pragma mark - MFMailComposeViewControllerDelegate


- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
    switch (result) {
        case MFMailComposeResultSent:
            [AppDelegate showMessage:@"Your Message is sent successfully"
                           withColor:[UIColor greenColor]
                         alertOnView:self.view];
            break;
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultFailed:
            [AppDelegate showError:error
                       alertOnView:self.view];
            break;
        case MFMailComposeResultSaved:
            [AppDelegate showMessage:@"Your Message is saved successfully"
                           withColor:NAVBAR_COLOR
                         alertOnView:self.view];
            break;
        default:
            break;
    }
}


@end
