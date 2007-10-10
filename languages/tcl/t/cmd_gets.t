#!tcl

# Copyright (C) 2006-2007, The Perl Foundation.
# $Id$

source lib/test_more.tcl
plan 3

eval_is {gets} \
  {wrong # args: should be "gets channelId ?varName?"} \
  {no args}

eval_is {gets a b c} \
  {wrong # args: should be "gets channelId ?varName?"} \
  {too many args}

eval_is {gets #parrot} \
  {can not find channel named "#parrot"} \
  {bad channel}

# RT#40628: Need to test actually reading something in.
