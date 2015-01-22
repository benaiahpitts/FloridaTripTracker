/**  CycleTracks, Copyright 2009-2013 San Francisco County Transportation Authority
 *                                    San Francisco, CA, USA
 *
 *   @author Matt Paul <mattpaul@mopimp.com>
 *
 *   This file is part of CycleTracks.
 *
 *   CycleTracks is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   CycleTracks is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with CycleTracks.  If not, see <http://www.gnu.org/licenses/>.
 */

//
//	PickerViewController.m
//	CycleTracks
//
//  Copyright 2009-2013 SFCTA. All rights reserved.
//  Written by Matt Paul <mattpaul@mopimp.com> on 9/28/09.
//	For more information on the project, 
//	e-mail Elizabeth Sall at the SFCTA <elizabeth.sall@sfcta.org>


#import "CustomView.h"
#import "TripQuestionsViewController.h"
#import "TravelModePickerViewDataSource.h"


@implementation TripQuestionsViewController

@synthesize customPickerView, customPickerDataSource, delegate, description;

@synthesize accidentSegment, fareCost, fareQuestion, householdMembers,nonHouseholdMembers, parkingCost, parkingSegment, scrollView, tollCost, tollSegment, travelModePicker, tmDataSource;


// return the picker frame based on its size
- (CGRect)pickerFrameWithSize:(CGSize)size
{
	
	// layout at bottom of page
	/*
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
									screenRect.size.height - 84.0 - size.height,
									size.width,
									size.height);
	 */
	
	// layout at top of page
	//CGRect pickerRect = CGRectMake(	0.0, 0.0, size.width, size.height );	
	
	// layout at top of page, leaving room for translucent nav bar
	//CGRect pickerRect = CGRectMake(	0.0, 43.0, size.width, size.height );	
	CGRect pickerRect = CGRectMake(	0.0, 78.0, size.width, size.height );	
	return pickerRect;
}


- (void)createCustomPicker
{
	customPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	customPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	// setup the data source and delegate for this picker
	customPickerDataSource = [[CustomPickerDataSource alloc] init];
	customPickerDataSource.parent = self;
	customPickerView.dataSource = customPickerDataSource;
	customPickerView.delegate = customPickerDataSource;
	
	// note we are using CGRectZero for the dimensions of our picker view,
	// this is because picker views have a built in optimum size,
	// you just need to set the correct origin in your view.
	//
	// position the picker at the bottom
	CGSize pickerSize = [customPickerView sizeThatFits:CGSizeZero];
	customPickerView.frame = [self pickerFrameWithSize:pickerSize];
	
	customPickerView.showsSelectionIndicator = YES;
	
	// add this picker to our view controller, initially hidden
	//customPickerView.hidden = YES;
	[self.view addSubview:customPickerView];
}


- (IBAction)cancel:(id)sender
{
	[delegate didCancelPurpose];
}


- (IBAction)save:(id)sender
{
	NSInteger row = [customPickerView selectedRowInComponent:0];
	NSMutableDictionary *tripAnswers= [[NSMutableDictionary alloc] init];
	
	[tripAnswers setObject:[delegate getPurposeString:(int)row] forKey:@"purpose"];
	[tripAnswers setObject:[[travelModePicker delegate] pickerView:travelModePicker titleForRow:[travelModePicker selectedRowInComponent:0] forComponent:0] forKey:@"travelBy"];
	[tripAnswers setObject:[NSNumber numberWithInt:[[householdMembers text] intValue]] forKey:@"members"];
	[tripAnswers setObject:[NSNumber numberWithInt:[[nonHouseholdMembers text] intValue]] forKey:@"nonmembers"];
	[tripAnswers setObject:[NSNumber numberWithFloat:[[tollCost text] floatValue]] forKey:@"tollAmt"];
	[tripAnswers setObject:[NSNumber numberWithFloat:[[parkingCost text] floatValue]] forKey:@"payForParkingAmt"];
	[tripAnswers setObject:[NSNumber numberWithFloat:[[fareCost text] floatValue]] forKey:@"fare"];
	[tripAnswers setObject:(([accidentSegment selectedSegmentIndex] == 0) ? [NSNumber numberWithInt:0] : [NSNumber numberWithInt:1]) forKey:@"delays"];
	[tripAnswers setObject:(([tollSegment selectedSegmentIndex] == 0) ? [NSNumber numberWithInt:0] : [NSNumber numberWithInt:1]) forKey:@"toll"];
	[tripAnswers setObject:(([parkingSegment selectedSegmentIndex] == 0) ? [NSNumber numberWithInt:0] : [NSNumber numberWithInt:1]) forKey:@"payForParking"];
	/*[tripAnswers setObject:(([accidentSegment selectedSegmentIndex] == 0) ? (@"NO") : (@"YES")) forKey:@"delays"];
	[tripAnswers setObject:(([tollSegment selectedSegmentIndex] == 0) ? (@"NO") : (@"YES")) forKey:@"toll"];
	[tripAnswers setObject:(([parkingSegment selectedSegmentIndex] == 0) ? (@"NO") : (@"YES")) forKey:@"payForParking"];*/
	
	
	[delegate didPickPurpose: tripAnswers];
}

- (IBAction)backgroundTouched:(id)sender {
	[fareCost resignFirstResponder];
	[householdMembers resignFirstResponder];
	[nonHouseholdMembers resignFirstResponder];
	[parkingCost resignFirstResponder];
	[tollCost resignFirstResponder];
}

- (IBAction)segmentChanged:(id)sender {
	if ([sender tag] == 1) {
		if ([sender selectedSegmentIndex] == 1) {
			[tollCost setText:@""];
			[tollCost setHidden:NO];
		}
		else [tollCost setHidden:YES];
	}
	
	else if ([sender tag] == 2) {
		if ([sender selectedSegmentIndex] == 1) {
			[parkingCost setText:@""];
			[parkingCost setHidden:NO];
		}
		else [parkingCost setHidden:YES];
	}
}


- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	NSLog(@"initWithNibNamed");
	if (self = [super initWithNibName:nibName bundle:nibBundle])
	{
		//NSLog(@"PickerViewController init");		
		[self createCustomPicker];
		
		// picker defaults to top-most item => update the description
		[self pickerView:customPickerView didSelectRow:0 inComponent:0];
	}
    
    CGSize cg;
    cg.height= fareCost.frame.size.height + fareCost.frame.origin.y + 20;
    cg.width= scrollView.frame.size.width;
    [scrollView setContentSize:cg];
	
	tmDataSource= [[TravelModePickerViewDataSource alloc] init];
	travelModePicker.dataSource= tmDataSource;
	travelModePicker.delegate= tmDataSource;
	tmDataSource.parent= self;
	
	// hide conditional fields
	[parkingCost setHidden:YES];
	[tollCost setHidden:YES];
	
	return self;
}


- (id)initWithPurpose:(NSInteger)index
{
	if (self = [self init])
	{
		//NSLog(@"PickerViewController initWithPurpose: %d", index);
		
		// update the picker
		[customPickerView selectRow:index inComponent:0 animated:YES];
		
		// update the description
		[self pickerView:customPickerView didSelectRow:index inComponent:0];
	}
	return self;
}


- (void)viewDidLoad
{		
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"Trip Purpose", @"");

	//self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	// self.view.backgroundColor = [[UIColor alloc] initWithRed:40. green:42. blue:57. alpha:1. ];

	// Set up the buttons.
	/*
	UIBarButtonItem* done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
															  target:self action:@selector(done)];
	done.enabled = YES;
	self.navigationItem.rightBarButtonItem = done;
	 */
	//[self.navigationController setNavigationBarHidden:NO animated:YES];
	
	//description = [[UITextView alloc] initWithFrame:CGRectMake( 18.0, 280.0, 284.0, 130.0 )];
	//description = [[UITextView alloc] initWithFrame:CGRectMake( 18.0, 314.0, 284.0, 120.0 )];
	description.editable = NO;
	description.font = [UIFont fontWithName:@"Arial" size:16];
	//[self.view addSubview:description];
	[fareCost setText:@""];
	[fareQuestion setHidden:YES];
	[fareCost setHidden:YES];
}


// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
//
- (void)viewDidUnload
{
	[super viewDidUnload];
	self.customPickerView = nil;
	self.customPickerDataSource = nil;
}

# pragma mark - UITextFieldDelegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
	[textField endEditing:YES];
	[textField resignFirstResponder];
	return YES;
}


#pragma mark UIPickerViewDelegate


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	NSLog(@"picker view tag:%d", pickerView.tag);

	if (pickerView.tag == 1) {
		switch (row) {
			case 1:
				[fareQuestion setHidden:NO];
				[fareCost setHidden:NO];
				break;
			case 0:
			case 2:
			case 3:
			case 4:
			case 5:
			case 6:
			case 7:
			default:
				[fareCost setText:@""];
				[fareQuestion setHidden:YES];
				[fareCost setHidden:YES];
				break;
		}
	}
	else {
		switch (row) {
			case 0:
				description.text = kDescCommute;
				break;
			case 1:
				description.text = kDescSchool;
				break;
			case 2:
				description.text = kDescWork;
				break;
			case 3:
				description.text = kDescExercise;
				break;
			case 4:
				description.text = kDescSocial;
				break;
			case 5:
				description.text = kDescShopping;
				break;
			case 6:
				description.text = kDescErrand;
				break;
			case 7:
			default:
				description.text = kDescOther;
				break;
		}
	}
}


@end

