import Darwin

do {
  let args = Array(CommandLine.arguments.dropFirst())
  try Lox().main(args: args)
} catch {
  print("ERROR -- \(error.localizedDescription)")
  exit(1)
}
