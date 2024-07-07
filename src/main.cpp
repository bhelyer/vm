#include <format>
#include <string>
#include <fstream>
#include <iostream>
#include <stdexcept>

#include "Pinot/VM.h"
#include "Pinot/Memory.h"

[[nodiscard]] std::vector<uint8_t> load(const std::string& filename);
[[nodiscard]] int run(const std::vector<uint8_t>& prog);

// Read a binary file into memory and run the VM on it.
int main(int argc, char** argv)
{
    if (argc != 2)
    {
        std::cerr << "usage: " << argv[0] << " file_to_run.bin\n";
        return 1;
    }

    try
    {
        const std::vector<uint8_t> prog = load(argv[1]);
        return run(prog);
    }
    catch (const std::exception& e)
    {
        std::cerr << "error: " << e.what() << '\n';
        return 1;
    }
    
    // Never reached.
}

// Load a file into a vector of bytes, or throw a runtime_error.
std::vector<uint8_t> load(const std::string& filename)
{
    // Open the file.
    std::ifstream ifs(filename, std::ios::in | std::ios::binary);
    if (!ifs)
    {
        auto msg = std::format("Failed to open '{}' for reading.", filename);
        throw std::runtime_error(msg);
    }

    // Calculate the size of the file.
    ifs.seekg(0, std::ios::end);
    const auto size = ifs.tellg();
    ifs.seekg(0);  // Rewind.

    // Read the data into a vector.
    std::vector<uint8_t> data(size);
    ifs.read(reinterpret_cast<char*>(data.data()), data.size());
    if (!ifs)
    {
        auto msg = std::format("Failed to read '{}'.", filename);
        throw std::runtime_error(msg);
    }

    return data;
}

// Construct a VM with the given program loaded, run it, and return R0.
int run(const std::vector<uint8_t>& prog)
{
    Pinot::Memory mem(prog.size());
    mem.copy(0, prog);
    Pinot::VM vm(mem);
    vm.run();
    return static_cast<int>(vm.read64(Pinot::Register::R0));
}