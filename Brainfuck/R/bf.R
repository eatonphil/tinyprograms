args <- commandArgs(trailingOnly=TRUE)

program <- strsplit(readLines(args[1]), "")[[1]]

dataStack <- c(rep(0, 30000))
dataPointer <- 1

instructionStack <- c()
instructionPointer <- 1

while (instructionPointer < (length(program) + 1)) {
  switch (program[instructionPointer],
    '>' = dataPointer <- dataPointer + 1,
    '<' = dataPointer <- dataPointer - 1,
    '+' = dataStack[dataPointer] <- dataStack[dataPointer] + 1,
    '-' = dataStack[dataPointer] <- dataStack[dataPointer] - 1,
    '.' = cat(rawToChar(as.raw(dataStack[dataPointer]))),
    ',' = {
      c <- readChar(con = file("stdin"), nchars = 1)
      dataStack[dataPointer] <- c
    },
    '[' = {
      stack <- 1
      end <- instructionPointer + 1
      repeat {
        switch(program[end],
               '[' = stack <- stack + 1,
               ']' = {
                 stack <- stack - 1
                 if(stack == 0) {
                   break
                 }
               }
               )
        end <- end + 1
      }
      if(dataStack[dataPointer] == 0) {
        instructionPointer <- end
      } else {
        instructionStack <- append(instructionStack, instructionPointer - 1)
      }
    },
    ']' = {
      if(dataStack[dataPointer] != 0) {
        instructionPointer <- instructionStack[length(instructionStack)]
      }
      instructionStack <- instructionStack[1:(length(instructionStack)-1)]
    }
  )
  instructionPointer <- instructionPointer + 1
}
