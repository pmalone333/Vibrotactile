piezoDriver32('open','COM5');
load('singlehigh16_stim.mat');
piezoDriver32('load',uint16(t),uint16(s));
piezoDriver32('start');
piezoDriver32('close');