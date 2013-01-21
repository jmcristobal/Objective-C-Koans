//
//  AboutAssertions.m
//  ObjectiveCKoans
//
//  Created by Curtis Schofield
//  Copyright 2011 BlazingCloud, Curtis J Schofield
//

#if __has_feature(objc_arc)

// Extending NSObject
#import <Foundation/Foundation.h>

// Make reference to a Person and PhoneNumber before they exist
@class Person;
@class PhoneNumber;

@interface Person : NSObject

@property (nonatomic, strong) PhoneNumber *phoneNumber;
// Example : create the property thingy with 'strong' ARC property
//
// ARC Notes : http://www.mikeash.com/pyblog/friday-qa-2011-09-30-automatic-reference-counting.html
//
// More on ARC from the compiler team : http://clang.llvm.org/docs/AutomaticReferenceCounting.html
//
//  @property (nonatomic,strong) NSString *thingy;
@end

@interface PhoneNumber : NSObject
  // We would explicitly tell the ARC system that we want a weak reference to Person
  // ie: don't keep the Person around if it's only retained reference is weak
@property (nonatomic, strong) Person *owner;
@property(nonatomic,strong) NSString *countryCode, *areaCode, *digits;

-(id)initWithCountryCode:(NSString*)countryCode areaCode:(NSString*)areaCode digits:(NSString*)digits;

@end

@implementation Person
@synthesize phoneNumber = _phoneNumber;

-(void)setPhoneNumber:(PhoneNumber *)phoneNumber{
	_phoneNumber = phoneNumber;
	phoneNumber.owner = self;
}

@end;

@implementation PhoneNumber

@synthesize owner = _owner;
@synthesize countryCode = _countryCode;
@synthesize areaCode = _areaCode;
@synthesize digits = _digits;

-(id)initWithCountryCode:(NSString *)countryCode areaCode:(NSString *)areaCode digits:(NSString *)digits{
	PhoneNumber *result = [PhoneNumber alloc];
	result.countryCode = countryCode;
	result.areaCode = areaCode;
	result.digits = digits;
	return result;
}

@end;


#import "Kiwi.h"
SPEC_BEGIN(AboutARC)

describe(@"About Automatic Reference Counting", ^{
  
  context(@"PhoneNumber",^{
    __block PhoneNumber * phoneNumber;
    
    beforeAll(^{
      phoneNumber = [[PhoneNumber alloc] 
                     initWithCountryCode:@"1"
                                areaCode:@"604" 
                                  digits:@"334-3244"];
    });
    it(@"can be initalized with area code and digits and countryCode without an owner", ^{
      
      [[theValue(phoneNumber.areaCode) should] equal:theValue(@"604")];
      [[theValue(phoneNumber.digits) should] equal:theValue(@"334-3244")];
      [[theValue(phoneNumber.countryCode) should] equal:theValue(@"1")];
      
      [phoneNumber.owner shouldBeNil];
      
    });
    it(@"can have an owner set",^{
      Person *aPerson = [[Person alloc] init];
      [phoneNumber setOwner:aPerson];
      [phoneNumber.owner shouldNotBeNil];
      [[phoneNumber.owner should] beIdenticalTo:aPerson];    
    });
    it(@"arc disables retain",^{
      // [phoneNumber retain];
      // bypassing ARC  will create memory leaks
      //[phoneNumber performSelector:NSSelectorFromString(@"retain")];      
    });
  });
  
  context(@"Person",^{
    it(@"sets a phone number to be owned by this person", ^{
      Person *me = [[Person alloc] init];
      PhoneNumber *phoneNumber = [[PhoneNumber alloc] initWithCountryCode:@"1" 
                                                                 areaCode:@"555" 
                                                                   digits:@"444-1234"];
      [me setPhoneNumber:phoneNumber];
      [[phoneNumber.owner should] beIdenticalTo:me];        
      
    });
  });
});
SPEC_END
#endif
