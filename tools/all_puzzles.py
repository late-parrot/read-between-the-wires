from generate_puzzle import *
from itertools import combinations, product

def get_all_rules(num_wires: int) -> list[Rule]:
    rules = []
    for a in range(num_wires):
        for b in range(num_wires):
            if a != b:
                rules.append(BeforeRule(a,b))
                rules.append(ImmediateRule(a,b))
        for c in WireColor:
            rules.append(BeforeColorRule(a,c))
    return rules

def get_all_puzzles(num_wires: int, limit: int = 0) -> list[Puzzle]:
    puzzles = []
    rules = get_all_rules(num_wires)
    all_colorsets = [list(cs) for cs in product(WireColor, repeat=num_wires)]
    all_rulesets = [set(rs) for rs in combinations(rules, num_wires)]
    for i, rs in enumerate(all_rulesets):
        print(i, "/", len(all_rulesets))
        for cs in all_colorsets:
            cs = list(cs)
            if len(valid_solutions(num_wires, cs, rs)) == 0:
                bad_rules = 0
                solution = []
                for r in rs:
                    if len(v := valid_solutions(num_wires, cs, rs-{r})) == 1:
                        bad_rules += 1
                        solution = v[0]
                if bad_rules == 1:
                    puzzles.append(Puzzle(rs, cs, solution))
                    if limit > 0 and len(puzzles) >= limit:
                        return puzzles
    return puzzles

print(len(get_all_puzzles(4, 100)))