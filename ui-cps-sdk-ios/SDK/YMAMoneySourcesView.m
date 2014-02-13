//
//  YMAMoneySourcesView.m
//  ui-cps-sdk-ios
//
//  Created by mertvetcov on 06.02.14.
//  Copyright (c) 2014 Yandex.Money. All rights reserved.
//

#import "YMAMoneySourcesView.h"
#import "YMAUIConstants.h"

@interface YMAMoneySourcesView () <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
}

@property(nonatomic, strong) NSMutableArray *moneySources;
@property(nonatomic, strong, readonly) UITableView *tableView;
@property(nonatomic, strong) UIViewController *parentController;
@property(nonatomic, strong) UIView *header;

@end

@implementation YMAMoneySourcesView

- (id)initWithMoneySources:(NSArray *)moneySources andViewController:(UIViewController *)controller {
    self = (controller) ? [super initWithFrame:controller.view.frame] : [super init];
    
    if (self) {
        _moneySources = [NSMutableArray arrayWithArray:moneySources];
        _parentController = controller;
        [self setupControls];
    }
    
    return self;
}

- (void)setupControls {
    self.backgroundColor = [YMAUIConstants defaultBackgroungColor];
    [self addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.parentController.navigationItem.title = YMALocalizedString(@"NBTMoneySourceTitle", nil);
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:YMALocalizedString(@"NBBCancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismissController)];
    barButton.tintColor = [YMAUIConstants accentTextColor];
    
    self.parentController.navigationItem.leftBarButtonItems = @[barButton];
    self.parentController.navigationItem.rightBarButtonItems = @[];
    
    UIImageView *ymLogoView = [[UIImageView alloc] initWithImage:YMALocalizedImage(@"ym", nil)];
    CGRect logoRect = ymLogoView.frame;
    
    logoRect.origin.y = self.frame.size.height - 110;
    logoRect.origin.x = (self.frame.size.width - logoRect.size.width)/2;
    ymLogoView.frame = logoRect;
    
    [self addSubview:ymLogoView];
}

- (void)dismissController {
    [self.parentController dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -
#pragma mark *** TableView  delegate ***
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.moneySources.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCellHeightDefault;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (section == 0) ? kCellHeightWithTextField : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return (section == 0) ? self.header : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"moneySourceCellID";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    
    if (indexPath.row < self.moneySources.count) {
        YMAMoneySource *moneySource = [self.moneySources objectAtIndex:indexPath.row];
        
        if (moneySource.cardType == YMAPaymentCardTypeVISA)
            cell.imageView.image = YMALocalizedImage(kImageKeyCardVISA, nil);
        else if (moneySource.cardType == YMAPaymentCardTypeMasterCard)
            cell.imageView.image = YMALocalizedImage(kImageKeyCardMasterCard, nil);
        else if (moneySource.cardType == YMAPaymentCardTypeAmericanExpress)
            cell.imageView.image = YMALocalizedImage(kImageKeyCardAmericanExpress, nil);
        else
            cell.imageView.image = YMALocalizedImage(kImageKeyCardDefault, nil);
        
        cell.textLabel.text = moneySource.panFragment;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    } else if (indexPath.row == self.moneySources.count) {
        cell.textLabel.text = YMALocalizedString(@"CTNewCard", nil);
        cell.textLabel.textColor = [YMAUIConstants accentTextColor];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        YMAMoneySource *moneySource = [self.moneySources objectAtIndex:indexPath.row];
        [self.delegate removeMoneySource:moneySource];
        [self.moneySources removeObject:moneySource];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < self.moneySources.count) {
        YMAMoneySource *moneySource = [self.moneySources objectAtIndex:indexPath.row];
        [self.delegate didSelectedMoneySource:moneySource];
    } else if (indexPath.row == self.moneySources.count) {
        
        //TODO use image for back button
        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self.delegate action:@selector(showAllMoneySource)];
        leftBarButton.tintColor = [YMAUIConstants accentTextColor];
        
        self.parentController.navigationItem.leftBarButtonItems = @[leftBarButton];        
        self.parentController.navigationItem.title = YMALocalizedString(@"NBTMainTitle", nil);
        
        self.parentController.navigationItem.rightBarButtonItems = @[];
        
        [self.delegate paymentFromNewCard];
    }
}

#pragma mark -
#pragma mark *** Getters and setters ***
#pragma mark -

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.frame style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
    }
    
    return _tableView;
}

- (UIView *)header {
    if (!_header) {
        _header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kCellHeightWithTextField)];
        _header.backgroundColor = [YMAUIConstants defaultBackgroungColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, kCellHeightWithTextField/2, self.frame.size.width, kCellHeightWithTextField/2)];
        label.textColor = [YMAUIConstants commentColor];
        label.font = [YMAUIConstants commentFont];
        label.text = YMALocalizedString(@"THMoneySources", nil);
        
        [_header addSubview:label];
    }
    
    return _header;
}

@end
