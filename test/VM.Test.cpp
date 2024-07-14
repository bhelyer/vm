#include "gtest/gtest.h"

#include "Pinot/VM.h"
#include "Pinot/Memory.h"

TEST(VMTest, registers_start_zeroed)
{
    Pinot::Memory mem(32);
    Pinot::VM vm(mem);
    for (uint8_t i = 0; i < static_cast<uint8_t>(Pinot::Register::Max); ++i)
    {
        EXPECT_EQ(vm.read64(static_cast<Pinot::Register>(i)), 0);
    }
}