---
guide: Getting Started
section: Installation
menu: getting-started
---

To run Lita, the following software is required:

* Ruby, version 2.0 or greater (JRuby 9.0.0.0+ or Rubinius 2+ also work)
* Redis, version 2.6 or greater

If you don't already have your own development environment with these dependencies installed, there are two approaches to take to get started with Lita.

### Lita Development Environment {#development-environment}

The easiest way to get started with Lita is to use the Lita Development Environment, a virtual machine provided specifically for Lita development. The Lita Development Environment has the same steps to set up on any operating system (OS X, Linux, or Windows) and handles the installation of Ruby, Redis, and Lita for you.

To use the Lita Development Environment, follow these steps:

1.  Install [Vagrant](https://www.vagrantup.com/) for your operating system.

1.  Install [VirtualBox](https://www.virtualbox.org/), the virtualization software Vagrant uses behind the scenes. (If you're already a Vagrant user and you prefer using a [VMware](https://www.vmware.com/) provider, you don't need to install VirtualBox. The Lita Development Environment supports both providers.)

1.  Git clone the repository:

    ~~~
    git clone https://github.com/litaio/development-environment.git lita-dev
    ~~~

1.  Move into the newly cloned repository:

    ~~~
    cd lita-dev
    ~~~

1.  Start the Vagrant VM:

    ~~~
    vagrant up
    ~~~

    This will take a few minutes the first time you do it. You'll want to be on a fast, stable Internet connection.

1.  SSH into the VM:

    ~~~
    vagrant ssh
    ~~~

1.  Once connected to the VM through SSH, start the Lita Development Environment:

    ~~~
    lita-dev
    ~~~

#### Next steps

At this point, you will find yourself in a shell in a Debian system with Lita already installed.

To create a new Lita project, run:

~~~
lita new .
~~~

This will generate a Gemfile and a lita_config.rb file, which you will eventually edit to configure Lita.

Ensure all dependencies are installed by running `bundle`

~~~
bundle
~~~


For a full list of commands Lita supports, run:

~~~
lita help
~~~

You must interact with the `lita` and `bundle` commands inside the Lita Development Environment, but you can edit your project files either inside the VM or on your host system with the editor of your choice &mdash; the directory you're in inside the Lita Development Environment is shared with the "workspace" directory in the Git repository you cloned on your host system.

When you're done, run <kbd>exit</kbd> to leave the Lita Development Environment, then run <kbd>exit</kbd> again to disconnect from the Vagrant VM.

<div class="alert alert-info">
  <strong>Note:</strong>
  Keep in mind that the Vagrant VM will still be running and using your computer's CPU and memory until you stop it. Stop the Vagrant VM with <kbd>vagrant halt</kbd>. If you want to use it again, just run <kbd>vagrant up</kbd> again to boot it up. If you're completely finished with it and want to remove the VM from your system, run <kbd>vagrant destroy</kbd>.
</div>

### Manual installation {#manual-installation}

Methods for installing Ruby 2.0 vary a lot between systems and are largely beyond the scope of this documentation. However, here are some quick tips for various operating systems:

#### Ruby implementations

Lita works with all the major implementations of Ruby: MRI, JRuby, and Rubinius. The minimum required version of JRuby is 9.0.0.0. The minimum required version of Rubinius is 2.2. Because JRuby does not support fork/exec, Lita's built-in process daemonization will not work, but this feature is going to be removed in the next version of Lita and should not be relied on anyway.

#### Installing Ruby

##### Linux

Ruby is available via many Linux distribution's package managers. The distribution may only package an older (1.x) version of Ruby, in which case you will need to compile it yourself. For Ubuntu, check out [Brightbox's Ubuntu Ruby packages](http://brightbox.com/docs/ruby/ubuntu/).

##### Mac OS X

Mac OS X 10.9 Mavericks or higher comes with Ruby 2.0 already installed, although the some commands may require you to use <kbd>sudo</kbd> for the correct permissions. Another good choice is installing a Ruby package with [Homebrew](http://brew.sh/).

##### Compiling from source on a Unix-like system

[ruby-build](https://github.com/sstephenson/ruby-build) automates the compilation process for you.

##### Windows

[RubyInstaller](http://rubyinstaller.org/) is a good choice.

#### Installing Redis

Redis installation is generally easier. Packages are available for most Unix-like systems. Compiling from source is also very straightforward. See the documentation on the [Redis](http://redis.io/) website for details.

#### Installing Lita

Given that you have working installations of the dependent software (Ruby and Redis), installing Lita is as simple as running the following command in your shell:

~~~
gem install lita
~~~

Once Lita is installed, create a new Lita project with this shell command:

~~~
lita new
~~~

This will generate a new directory called "lita" with a Gemfile and Lita configuration file, which is all you need to configure and run Lita.

For a full list of possible invocations of the `lita` command, run:

~~~
lita help
~~~

If you run into any errors that result in `Bundler::GemNotFound`, you can always let bundler install any dependencies for you:

~~~
bundle
~~~
