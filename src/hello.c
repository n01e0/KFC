#include <linux/module.h>

MODULE_LICENSE("GPL v2");
MODULE_AUTHOR("n01e0");
MODULE_DESCRIPTION("Hello kernel kmod");

static int hello_init(void) {
    printk(KERN_ALERT "Hello kernel!\n");
    return 0;
}

static void bye_exit(void) {
    printk(KERN_ALERT "Good bye kernel!\n");
}

module_init(hello_init);
module_exit(bye_exit);
