#-------------------------------------------------------------------------------
CXX ?= g++

CXXFLAGS += -c -std=c++11 -Wall $(shell pkg-config --cflags opencv)
LDFLAGS += $(shell pkg-config --libs --static opencv -lOpenCL)

CC = g++
CFLAGS = -g -Wall
SRCS = BayernOpenCL.cpp
PROG = bayer_open_cl

OPENCV = `pkg-config opencv --cflags --libs`
OPENCL=-lOpenCL

LIBS = $(OPENCV) $(OPENCL)

#-------------------------------------------------------------------------------

$(PROG):$(SRCS)
	$(CC) $(CFLAGS) -o $(PROG) $(SRCS) $(LIBS)
all: $(ALL)


clean:
	rm -f $(PROG)
