#import <Orion/Orion.h>
#import "Tweak.h"

__attribute__((constructor)) static void init() {
    // Initialize Orion - do not remove this line.
    orion_init();
//    PeerListViewController = NSClassFromString(@"vkm.PeerListViewController");
    // Custom initialization code goes here.
}
