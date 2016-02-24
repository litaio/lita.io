---
guide: Getting Started
section: Usage
menu: getting-started
---

Once Lita is installed and configured, running it is simply a matter of running the shell command: <kbd>lita</kbd>

### Shell adapter {#shell-adapter}

Lita ships with one adapter for use directly in the shell. This is a great way to try it out without having to connect to a real chat service. Using the shell adapter, simply type text at the input to send messages, and Lita will respond according to any registered handlers.

The shell adapter has one configuration attribute:

{:.table .table-bordered}
Name | Type | Description | Default
--- | --- | --- | ---
`config.adapters.shell.private_chat` | Boolean | If true, all messages will be treated as though they were sent in a private chat, so they will be considered commands even when not prefixed with Lita's name. | `false`

The next section covers the distinction between "messages" and "commands".

### Messages and commands {#messages-and-commands}

Lita handlers can act on any message sent to it in a private message or that it overhears in a group chat room. Some handlers cause Lita to respond only when the matching phrase is a "command," which means that the message was sent to Lita privately, or it was specifically addressed to Lita in a public room. The following are all valid ways of addressing Lita:

~~~
You: Lita, do something
You: Lita do something
You: @Lita do something
You: Lita: do something
~~~

All of these will cause Lita to interpret the message as a command. Lita's name is also case insensitive. If the messages are sent privately, they are always considered commands and don't need to be prefixed with Lita's name.

### In-chat help {#in-chat-help}

Handler plugins register help information about the new features they add. You can find out what messages and commands Lita will respond to by sending it the message "help".

~~~
You: Lita help
~~~

Lita will reply to you privately with a list of available messages and commands. In some cases, this list might be very large and you'll want to filter it down to messages and commands containing a certain phrase. You can do that by adding the phrase you want to filter by to the end of the command:

~~~
You: Lita help karma
~~~

This will return messages and commands only if their help text contains the word "karma".

### Basic info {#basic-info}

Lita exposes some basic information about itself while it's running. To see the version of Lita that is currently running, use the *info* command.

~~~
You: Lita info
Lita: Lita 4.0.0 - http://www.lita.io/
Lita: Redis 2.8.12 - Memory used: 9.6M
~~~

An HTTP route is also exposed, containing additional information.

~~~
$ curl -i http://lita.example.com/lita/info
HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: 90

{"adapter":"shell","lita_version":"4.0.0","redis_memory_usage":"982.38K","redis_version":"2.8.17","robot_mention_name":"Lita","robot_name":"Lita"}
~~~

### Managing rooms {#managing-rooms}

The rooms Lita joins at start up time are defined in adapter-specific configuration. However, if you want to Lita to join a room temporarily while it's running, or leave a room it's joined, you can use the *join* and *part* commands.

~~~
You: Lita join #mychannel
You: Lita part #mychannel
~~~

<div class="alert alert-info">
  <strong>Note:</strong>
  These commands are an optional part of the adapter plugin interface and may not be implemented by every adapter.
</div>

### Authorization groups {#authorization-groups}

Handlers can restrict chat routes to certain users through the authorization groups feature. For example, certain commands in the [karma](https://github.com/jimmycuadra/lita-karma) plugin require the user sending the message to be in the `:karma_admins` group.

Authorization groups can be arbitrarily named, and are created and destroyed automatically when members are added and removed. To manage authorization groups, a user must be specified as an administrator via the `config.robot.admins` configuration attribute.

To add a user to a group:

~~~
 You: Lita auth add Joe karma_admins
Lita: Joe was added to karma_admins.
~~~

Similarly, to remove a user from a group:

~~~
 You: Lita auth remove Joe karma_admins
Lita: Joe was removed from karma_admins.
~~~

To see all the current authorization groups and their members:

~~~
 You: Lita auth list
Lita: karma_admins: You
~~~

In the add and remove commands, the user can be specified by their unique ID, their display name, or their "mention name," on chat services that have such a user property.

### User info {#user-info}

Lita stores a record for each user it encounters with information including their name, their "mention name," and a unique ID that never changes. The `config.robot.admins` configuration attribute requires the unique IDs of users that should be considered administrators. With some adapters, this ID may not be something you can determine from the chat service's user interface. Fortunately, you can look up the basic information stored for each user by sending the `users find` command to Lita:

~~~
You: Lita users find joe
Lita: Joe (ID: U92CJ39, Mention name: joe)
~~~

The value at the end of the `users find` command is a search term that can be the user's ID, display name, or mention name. If a matching user is found, Lita will reply with the user's information. The ID displayed in the response is the ID that should be used to mark this user as an administrator via the `config.robot.admins` attribute in the `lita_config.rb` file.
