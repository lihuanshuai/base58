<!--
 Copyright 2025 lihuanshuai

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->

# base58

[Zig](https://ziglang.org/) implementation of base58 encoding

## Usage

```zig
const std = @import("std");
const base58 = @import("base58");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const input = "Hello World!";
    const encoded = try base58.encode(allocator, input);
    defer allocator.free(encoded);

    std.debug.print("{s}\n", .{encoded});  // Output: 2NEpo7TZRRrLZSi2U
}
```

## Build

```bash
zig build
```

## Run

```bash
zig run src/main.zig
```

## Test

```bash
zig test src/main.zig
```

## Reference

- [base58](https://en.wikipedia.org/wiki/Base58)
