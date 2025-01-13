import Foundation

let arguments = CommandLine.arguments

// Check if the correct number of arguments are provided
if arguments.count == 5 {
    // Initialize the generator with the provided paths
    let generator = OpenAPIHandlerGen(
        openAPIPath: arguments[1],
        serverPath: arguments[2],
        typesPath: arguments[3],
        outputPath: arguments[4]
    )
    
    // Execute the generator
    do {
        try generator.run()
        print("Generation completed successfully.")
    } catch {
        // Handle errors during generation
        print("Error occurred during generation: \(error)")
    }
} else {
    // Print usage instructions
    print("""
    Usage: OpenAPIFluentGen <openapi.yaml> <Server.swift> <Types.swift> <outputPath>
    Example:
      OpenAPIFluentGen Sources/openapi.yaml Generated/Server.swift Generated/Types.swift output.swift
    """)
}
