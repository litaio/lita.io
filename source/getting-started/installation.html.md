---
guide: Getting Started
section: Installation
menu: getting-started
---

%p To run Lita, the following software is required:

%ul
  %li Ruby, version 2.0 or greater
  %li Redis, version 2.6 or greater

%p If you don't already have a development environment with these dependencies installed, there are two approaches to take to get started with Lita.

%h3#vagrant Vagrant

%p The easiest way to get started with Lita is to use the Vagrant virtual machine provided specifically for Lita development. If you're not familiar with it, Vagrant is a tool for managing complete development environments inside virtual machines. Using Vagrant and the Lita development environment, you can quickly boot a virtual Ubuntu machine with Ruby, Redis, and Lita pre-installed and ready to go. This VM works regardless of what type of computer you use &mdash; Linux, Mac OS X, and Windows are all supported by Vagrant. It takes just a few steps:

%ol
  %li Install <a href="http://www.vagrantup.com/">Vagrant</a> for your operating system.
  %li Install <a href="https://www.virtualbox.org/">VirtualBox</a>, the virtualization software Vagrant uses behind the scenes. (If you're already a Vagrant user and you prefer using a <a href="http://www.vmware.com/">VMware</a> provider, you don't need to install VirtualBox. The Lita development environment supports both providers.)
  %li Download and unzip the <a href="https://github.com/litaio/development-environment/archive/master.zip">Lita development environment</a>.
  %li In a terminal window, move into the Lita development environment directory, and run <kbd>vagrant up</kbd>. This will download the virtual machine and boot it. The first time you do this it will take a few minutes.
  %li Once the VM is finished booting, run <kbd>vagrant ssh</kbd> to connect.
  %li Inside the development environment, run <kbd>cd /vagrant</kbd> to move into the shared Vagrant directory. Everything in this directory is shared with the Lita development environment directory on your host system, and changes are reflected immediately.
  %li Run <kbd>lita new .</kbd> (note the period) to create a new Lita project. This will generate a Gemfile and Lita configuration file, which is all you need to configure and run Lita. For a full list of possible invocations of the <kbd>lita</kbd> command, run <kbd>lita help</kbd>.

%p You must interact with the <kbd>lita</kbd> and <kbd>bundle</kbd> commands inside the VM, but you can edit your project files either inside the VM or on your host system with the editor of your choice.

%h3#manual-installation Manual installation

%p Methods for installing Ruby 2.0 vary a lot between systems and are largely beyond the scope of this documentation. However, here are some quick tips for various operating systems:

%dl
  %dt Linux
  %dd Ruby is available via many Linux distribution's package managers. The distribution may only package an older (1.x) version of Ruby, in which case you will need to compile it yourself. For Ubuntu, check out <a href="http://brightbox.com/docs/ruby/ubuntu/">Brightbox's Ubuntu Ruby packages</a>.
  %dt Mac OS X
  %dd Mac OS X 10.9 Mavericks or higher comes with Ruby 2.0 already installed, although the some commands may require you to use <kbd>sudo</kbd> for the correct permissions. Another good choice is installing a Ruby package with <a href="http://brew.sh/">Homebrew</a>.
  %dt Compiling from source on a Unix-like system
  %dd <a href="https://github.com/sstephenson/ruby-build">ruby-build</a> automates the compilation process for you.
  %dt Windows
  %dd <a href="http://rubyinstaller.org/">RubyInstaller</a> is a good choice.

%p Redis installation is generally easier. Packages are available for most Unix-like systems. Compiling from source is also very straightforward. See the documentation on the <a href="http://redis.io/">Redis</a> website for details.

%p Given that you have working installations of the dependent software (Ruby and Redis), installing Lita is as simple as running the following command in your shell: <kbd>gem install lita</kbd>

%p Once Lita is installed, create a new Lita project with this shell command: <kbd>lita new</kbd>

%p This will generate a new directory called "lita" with a Gemfile and Lita configuration file, which is all you need to configure and run Lita.

%p For a full list of possible invocations of the <kbd>lita</kbd> command, run <kbd>lita help</kbd>.

.alert.alert-info
  %strong Note:
  If you are running Lita on JRuby, you'll need to use Ruby 2.0 mode, by invoking lita with <kbd>jruby --2.0 -S lita</kbd> or setting the environment variable <var>JRUBY_OPTS</var> to <var>--2.0</var>
