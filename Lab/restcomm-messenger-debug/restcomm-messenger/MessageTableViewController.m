//
//  MessageTableViewController.m
//  restcomm-messenger
//
//  Created by Antonis Tsakiridis on 9/23/15.
//  Copyright © 2015 TeleStax. All rights reserved.
//

#import "MessageTableViewController.h"
#import "InputAccessoryProxyView.h"
#import "Utilities.h"
#import "LocalMessageTableViewCell.h"
#import "RemoteMessageTableViewCell.h"
#import "Utils.h"

@interface MessageTableViewController ()
@property InputAccessoryProxyView * inputAccessoryProxyView;
@property (weak, nonatomic) IBOutlet UITextField *sipMessageText;
//@property (weak, nonatomic) IBOutlet UITextView *sipDialogText;
// how many messages have been written in the table so far
//@property int messageCount;
// backing store for table
@property NSMutableArray * messages;
@property BOOL pendingError;
@end

@implementation MessageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:235.0/255.0 green:91.0/255.0 blue:41.0/255.0 alpha:255.0/255.0];
    
    self.messages = [[NSMutableArray alloc] init];
    // allocate and insert proxy view. Important: the proxy view cannot be part of the view hierarchy in the storyboard/xib.
    // It needs to be added dynamically
    self.inputAccessoryProxyView = [[InputAccessoryProxyView alloc]initWithFrame:[UIScreen mainScreen].bounds viewController:self];
    // see if thi will work (used to be below sipDialogText
    [self.view insertSubview:self.inputAccessoryProxyView belowSubview:self.tableView];
    
    // setup table view so that it allows its cell's height to grow depending on the content's intrinsic size
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    
    // remove empty cells from tableview
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(proxyViewPressed)];
    [self.inputAccessoryProxyView addGestureRecognizer:recognizer];

    if ([self.parameters objectForKey:@"alias"]) {
        // alias is set only for local messages
        self.navigationItem.title = [self.parameters objectForKey:@"alias"];
    }
    else {
        self.navigationItem.title = [Utilities usernameFromUri:[self.parameters objectForKey:@"username"]];
    }
    
    self.messages = [[Utils messagesForAlias:[self.parameters objectForKey:@"alias"]] mutableCopy];
    //self.messageCount = [self.messages count];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)proxyViewPressed {
    [self.inputAccessoryProxyView becomeFirstResponder];
}

- (void)populateChatHistory
{
    /*
    NSString *type = [[self.messages objectAtIndex:indexPath.row] objectForKey:@"type"];
    if ([type isEqualToString:@"local"]) {
        LocalMessageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"local-message-reuse-identifier" forIndexPath:indexPath];
        cell.senderText.text = [[self.messages objectAtIndex:indexPath.row] objectForKey:@"text"];
     */

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.device.state == RCDeviceStateOffline) {
        self.pendingError = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"RCDevice not Connected"
                                                        message:@"No connectivity"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    // we need that so that the accessory view shows up right away
    [self.inputAccessoryProxyView becomeFirstResponder];
    
    // Incoming text message just arrived
    if ([[self.parameters valueForKey:@"invoke-view-type"] isEqualToString:@"receive-message"]) {
        [self appendToDialog:[self.parameters objectForKey:@"message-text"] sender:[self.parameters objectForKey:@"username"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)hideKeyBoard
{
    // resign both to be sure
    [self.sipMessageText resignFirstResponder];
}

// ---------- UI events
- (IBAction)sendMessagePressed:(id)sender
{
    NSMutableDictionary * parms = [NSMutableDictionary dictionaryWithObjectsAndKeys:[self.parameters objectForKey:@"username"], @"username",
                                   self.sipMessageText.text, @"message", nil];
    
    // SIP custom headers: uncomment this to use SIP custom headers
    //[parms setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Value1", @"Key1", @"Value2", @"Key2", nil]
    //                    forKey:@"sip-headers"];
    
    // send an instant message using RCDevice
    if (![self.device sendMessage:parms]) {
        //self.pendingError = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"RCDevice Error"
                                                        message:@"Not connected"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self appendToDialog:self.sipMessageText.text sender:@"Me"];
    self.sipMessageText.text = @"";
    
    [self.inputAccessoryProxyView becomeFirstResponder];
    // hide keyboard
    //[self.sipMessageText endEditing:false];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.pendingError) {
        self.pendingError = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

// helpers
- (void)appendToDialog:(NSString*)msg sender:(NSString*)sender
{
    NSString *username = [Utilities usernameFromUri:sender];
    // TODO: update the window title with the chat peer (do it once only)
    NSString * type = @"local";
    if (![username isEqualToString:@"Me"]) {
        type = @"remote";
    }
    // update the backing store and NSUserDefaults
    //[self.messages insertObject:[NSDictionary dictionaryWithObjectsAndKeys:type, @"type", msg, @"text", nil]
    //                    atIndex:self.messageCount++];
    [self.messages addObject:[NSDictionary dictionaryWithObjectsAndKeys:type, @"type", msg, @"text", nil]];
    [Utils addMessageForAlias:[self.parameters objectForKey:@"alias"]
                         text:msg
                         type:type];

    // trigger the new table row creation
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.messages count] - 1 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

/*
- (CGFloat)textViewHeightForRowAtIndexPath: (NSIndexPath*)indexPath {
    UITextView *calculationView = [textViews objectForKey: indexPath];
    CGFloat textViewWidth = calculationView.frame.size.width;
    if (!calculationView.attributedText) {
        // This will be needed on load, when the text view is not inited yet
        
        calculationView = [[UITextView alloc] init];
        calculationView.attributedText = // get the text from your datasource add attributes and insert here
        textViewWidth = 290.0; // Insert the width of your UITextViews or include calculations to set it accordingly
    }
    CGSize size = [calculationView sizeThatFits:CGSizeMake(textViewWidth, FLT_MAX)];
    return size.height;
}
 */

#pragma mark - Table view data source
/* No need to implement, we only have one section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // TODO: Return the number of rows in the section.
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *type = [[self.messages objectAtIndex:indexPath.row] objectForKey:@"type"];
    if ([type isEqualToString:@"local"]) {
        LocalMessageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"local-message-reuse-identifier" forIndexPath:indexPath];
        cell.senderText.text = [[self.messages objectAtIndex:indexPath.row] objectForKey:@"text"];
        return cell;
    }
    else {
        RemoteMessageTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"remote-message-reuse-identifier" forIndexPath:indexPath];
        cell.senderText.text = [[self.messages objectAtIndex:indexPath.row] objectForKey:@"text"];
        return cell;
    }
    //RemoteMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"remote-message-reuse-identifier" forIndexPath:indexPath];
    //cell.senderText.text = [[self.messages objectAtIndex:indexPath.row] objectForKey:@"text"];
    // Configure the cell...
    //NSArray * contact = [Utils contactForIndex:indexPath.row];
    //cell.textLabel.text = [contact objectAtIndex:0];
    //cell.detailTextLabel.text = [contact objectAtIndex:1];
    //UITextView * message = (UITextView*)
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // check here, if it is one of the cells, that needs to be resized
    // to the size of the contained UITextView
    if (  )
        return [self textViewHeightForRowAtIndexPath:indexPath];
    else
        // return your normal height here:
        return 100.0;
}
 */

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end