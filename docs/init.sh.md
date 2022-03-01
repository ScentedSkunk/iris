# init.sh - v0.0.73
initializer for iris


### _environment::init()

checks and readies environment for iris

*function has no arguments*

#### return codes:

- 1 unsupported bash version
- 2 unable to load default config
- 3 unable to load module
- 4 unable to load custom module

### _module::init::test()

checks if modules have init functions for prompt generation

#### arguments:

- $1: function to test

#### return codes:

- 0 function exists
- 1 function does not exist

### _prompt::color()

colors prompt information

#### arguments:

- $1: prompt information to color

### _prompt::output()

outputs prompt information

#### arguments:

- $1: prompt information to output

#### return codes:

- # @return_code 0: success

### _prompt::build()

builds prompt information

*function has no arguments*

### _prompt::generate()

generates prompt segments

#### arguments:

- $1: prompt information
- $2: color of prompt


