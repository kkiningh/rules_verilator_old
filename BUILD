package(default_visibility = ["//visibility:private"])

licenses(["notice"])

exports_files([
    "Artistic",
    "COPYING",
    "COPYING.LESSER",
])

sh_binary(
    name = "flexfix",
    srcs = ["src/flexfix"],
)

sh_binary(
    name = "bisonpre",
    srcs = ["src/bisonpre"],
)

genrule(
    name = "verilator_astgen",
    srcs = [
        "src/V3Ast.h",
        "src/V3AstNodes.h",
        "src/Verilator.cpp",
        "src/astgen",
    ],
    outs = [
        "V3Ast__gen_classes.h",
        "V3Ast__gen_impl.h",
        "V3Ast__gen_interface.h",
        "V3Ast__gen_report.txt",
        "V3Ast__gen_types.h",
        "V3Ast__gen_visitor.h",
    ],
    cmd = """
    perl $(location src/astgen) -I$$(dirname $(location src/V3Ast.h)) --classes
    cp V3Ast__gen_classes.h $(@D)
    cp V3Ast__gen_impl.h $(@D)
    cp V3Ast__gen_interface.h $(@D)
    cp V3Ast__gen_report.txt $(@D)
    cp V3Ast__gen_types.h $(@D)
    cp V3Ast__gen_visitor.h $(@D)
    """,
)

genrule(
    name = "verilator_astgen_const",
    srcs = [
        "src/V3Ast.h",
        "src/V3AstNodes.h",
        "src/V3Const.cpp",
        "src/Verilator.cpp",
        "src/astgen",
    ],
    outs = ["V3Const__gen.cpp"],
    cmd = """
    perl $(location src/astgen) -I$$(dirname $(location src/V3Const.cpp)) V3Const.cpp
    cp V3Const__gen.cpp $(@D)
    """,
)

genrule(
    name = "verilator_lex_pregen",
    srcs = ["src/verilog.l"],
    outs = ["V3Lexer_pregen.yy.cpp"],
    cmd = "flex -d -o$(@) $(<)",
)

genrule(
    name = "verilator_lex_flexfix",
    srcs = [":V3Lexer_pregen.yy.cpp"],
    outs = ["V3Lexer.yy.cpp"],
    cmd = "./$(location :flexfix) V3Lexer < $(<) > $(@)",
    tools = [":flexfix"],
)

genrule(
    name = "verilator_prelex_pregen",
    srcs = ["src/V3PreLex.l"],
    outs = ["V3PreLex_pregen.yy.cpp"],
    cmd = "flex -d -o$(@) $(<)",
)

genrule(
    name = "verilator_prelex_flexfix",
    srcs = [":V3PreLex_pregen.yy.cpp"],
    outs = ["V3PreLex.yy.cpp"],
    cmd = "./$(location :flexfix) V3PreLex < $(<) > $(@)",
    tools = [":flexfix"],
)

genrule(
    name = "config_rev",
    outs = ["src/config_rev.h"],
    cmd = """
    echo 'static const char* const DTVERSION_rev = "UNKNOWN_REV";' > $(@)
    """,
)

genrule(
    name = "config_build",
    srcs = ["src/config_build.h.in"],
    outs = ["src/config_build.h"],
    cmd = "cp $(<) $(@)",
)

genrule(
    name = "verilated_config",
    outs = ["include/verilated_config.h"],
    cmd = """
    echo '#define VERILATOR_PRODUCT "Verilator"\n#define VERILATOR_VERSION "4.014"' > $(@)
    """,
)

genrule(
    name = "verilator_bison",
    srcs = ["src/verilog.y"],
    outs = [
        "V3ParseBison.c",
        "V3ParseBison.h",
    ],
    cmd = "./$(location :bisonpre) --yacc bison -d -v -o $(location V3ParseBison.c) $(<)",
    tools = [":bisonpre"],
)

cc_library(
    name = "verilatedos",
    hdrs = ["include/verilatedos.h"],
    strip_include_prefix = "include/",
)

# TODO(kkiningh): Verilator also supports multithreading, should we enable it?
cc_library(
    name = "verilator_libV3",
    srcs = glob(
        ["src/V3*.cpp"],
        exclude = [
            "src/V3*_test.cpp",
            "src/V3Const.cpp",
        ],
    ) + [
        ":V3Ast__gen_classes.h",
        ":V3Ast__gen_impl.h",
        ":V3Ast__gen_interface.h",
        ":V3Ast__gen_types.h",
        ":V3Ast__gen_visitor.h",
        ":V3Const__gen.cpp",
        ":V3ParseBison.h",
    ],
    hdrs = glob(["src/V3*.h"]) + [
        ":src/config_build.h",
        ":src/config_rev.h",
    ],
    copts = [
        # TODO: We should probably set this later
        "-DDEFENV_SYSTEMC_INCLUDE=\\\"@invalid@\\\"",
        "-DDEFENV_SYSTEMC_LIBDIR=\\\"@invalid@\\\"",
        "-DDEFENV_VERILATOR_ROOT=\\\"@invalid@\\\"",
        # TODO: Remove these once upstream fixes these warnings
        "-Wno-unneeded-internal-declaration",
        # TODO: C++17 doesn't allow the register keyword.
        # This should probably be fixed another way
        # Note that this only affects flex < 2.6.0 (e.g. OSX)
        "-Wno-deprecated-register",
        "-Dregister= ",
    ],
    defines = ["YYDEBUG"],
    strip_include_prefix = "src/",
    textual_hdrs = [
        # These are included directly by other C++ files
        # See https://github.com/bazelbuild/bazel/issues/680
        ":V3Lexer.yy.cpp",
        ":V3PreLex.yy.cpp",
        ":V3ParseBison.c",
    ],
    deps = [":verilatedos"],
)

cc_library(
    name = "libverilator",
    srcs = [
        "include/gtkwave/fastlz.h",
        "include/gtkwave/fst_config.h",
        "include/gtkwave/fstapi.h",
        "include/gtkwave/lz4.h",
        "include/gtkwave/wavealloca.h",
        "include/verilated.cpp",
        "include/verilated_fst_c.cpp",
        "include/verilated_imp.h",
        "include/verilated_syms.h",
        "include/verilated_vcd_c.cpp",
    ],
    hdrs = [
        ":include/verilated_config.h",
        "include/verilated.h",
        "include/verilated_sc.h",
        "include/verilated_dpi.h",
        "include/verilated_fst_c.h",
        "include/verilated_heavy.h",
        "include/verilated_sym_props.h",
        "include/verilated_vcd_c.h",
        "include/verilatedos.h",
    ],
    strip_include_prefix = "include/",
    visibility = ["//visibility:public"],
    textual_hdrs = [
        "include/gtkwave/fastlz.c",
        "include/gtkwave/fstapi.c",
        "include/gtkwave/lz4.c",
    ],
    includes = ["include"],
    copts = [
        # TODO: C++17 doesn't allow the register keyword.
        # This should probably be fixed another way
        "-Wno-deprecated-register",
        "-Dregister= ",
    ],
)

cc_library(
    name = "svdpi",
    hdrs = [
        "include/vltstd/svdpi.h",
    ],
    strip_include_prefix = "include/vltstd",
    visibility = ["//visibility:public"],
)

cc_binary(
    name = "verilator_bin",
    srcs = ["src/Verilator.cpp"],
    visibility = ["//visibility:public"],
    deps = [":verilator_libV3"],
)
