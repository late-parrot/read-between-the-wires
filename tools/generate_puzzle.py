from random import shuffle, choice, randint
from itertools import permutations, combinations, product
from dataclasses import dataclass
from abc import ABC, abstractmethod
from enum import Enum
from pathlib import Path
import json

class WireColor(Enum):
    RED = "red"
    GREEN = "green"
    BLUE = "blue"

class Rule(ABC):
    @abstractmethod
    def is_valid(self, colors: list[WireColor], answer: list[int]) -> bool: pass
    @abstractmethod
    def as_dict(self) -> dict: pass
    @classmethod
    @abstractmethod
    def random(cls, num_wires: int, colors: list[WireColor]) -> 'Rule': pass

@dataclass
class BeforeRule(Rule):
    first: int
    second: int
    def is_valid(self, colors: list[WireColor], answer: list[int]) -> bool:
        return answer.index(self.first) < answer.index(self.second)
    def as_dict(self) -> dict:
        return {"type": "before", "first": self.first, "second": self.second}
    @classmethod
    def random(cls, num_wires: int, colors: list[WireColor]) -> 'BeforeRule':
        first = randint(0, num_wires-1)
        second = randint(0, num_wires-1)
        while second == first:
            second = randint(0, num_wires-1)
        return BeforeRule(first, second)
    def __str__(self):
        return f"Wire {self.first} must be cut before wire {self.second}"
    def __hash__(self) -> int:
        return hash(tuple(self.as_dict().values()))

@dataclass
class ImmediateRule(Rule):
    first: int
    second: int
    def is_valid(self, colors: list[WireColor], answer: list[int]) -> bool:
        return answer.index(self.first)+1 == answer.index(self.second)
    def as_dict(self) -> dict:
        return {"type": "immediate", "first": self.first, "second": self.second}
    @classmethod
    def random(cls, num_wires: int, colors: list[WireColor]) -> 'ImmediateRule':
        first = randint(0, num_wires-2)
        return ImmediateRule(first, first+1)
    def __str__(self):
        return f"Wire {self.first} must be cut immediately before wire {self.second}"
    def __hash__(self) -> int:
        return hash(tuple(self.as_dict().values()))

@dataclass
class BeforeColorRule(Rule):
    # This wire (number) must be cut before any wires of this color.
    number: int
    color: WireColor
    def is_valid(self, colors: list[WireColor], answer: list[int]) -> bool:
        return all(answer.index(self.number) < i for i in answer if colors[answer[i]]==self.color)
    def as_dict(self) -> dict:
        return {"type": "before_color", "number": self.number, "color": self.color.value}
    @classmethod
    def random(cls, num_wires: int, colors: list[WireColor]) -> 'BeforeColorRule':
        number = randint(0, num_wires-1)
        color = choice([c for c in WireColor if c != colors[number]])
        return BeforeColorRule(number, color)
    def __str__(self):
        return f"Wire {self.number} must be cut before any {self.color.value} wires"
    def __hash__(self) -> int:
        return hash(tuple(self.as_dict().values()))

@dataclass
class Puzzle:
    rules: set[Rule]
    colors: list[WireColor]
    solution: list[int]
    def as_dict(self):
        return {"rules": [r.as_dict() for r in self.rules], "colors": [c.value for c in self.colors], "solution": self.solution}

def random_rule(num_wires: int, colors: list[WireColor]) -> Rule:
    t = choice((BeforeRule, ImmediateRule, BeforeColorRule))
    return t.random(num_wires, colors)

def valid_solutions(num_wires: int, colors: list[WireColor], rules: set[Rule]) -> list[list[int]]:
    ps = [list(p) for p in permutations(range(num_wires))]
    return [p for p in ps if all(r.is_valid(colors, p) for r in rules)]

    # prereqs = {i:set() for i in range(num_wires)}
    # for r in rules:
    #     prereqs[r.second].add(r.first)

    # def search(remaining: set[int], placed: list[int]):
    #     if not remaining:
    #         return [placed]
    #     solutions = []
    #     for w in remaining:
    #         if prereqs[w].issubset(placed):
    #             new_remaining = remaining - {w}
    #             new_placed = placed + [w]
    #             solutions += search(new_remaining, new_placed)
    #     return solutions
    
    # return search(set(range(num_wires)), [])

def basic_puzzle(num_wires: int) -> Puzzle:
    solution = list(range(num_wires))
    shuffle(solution)
    colors = [choice([c for c in WireColor]) for _ in range(num_wires)]
    possible_rules = [
        BeforeRule(a, b)
        for i, a in enumerate(solution)
        for b in solution[i+1:]
    ] + [
        ImmediateRule(a, solution[i+1])
        for i, a in enumerate(solution[:-1])
    ] + [
        BeforeColorRule(w, c)
        for i, w in enumerate(solution)
        for c in set(colors)
        if all(i < j for j in solution if colors[solution[j]]==c)
    ]
    #print(solution)#, possible_rules)
    rules = set()
    while len(valid := valid_solutions(num_wires, colors, rules)) > 1:
        c = choice(possible_rules)
        possible_rules.remove(c)
        rules.add(c)
        if len(new := valid_solutions(num_wires, colors, rules)) >= len(valid):
            rules.remove(c)
        elif len(new) == 0:
            rules.remove(c)
        elif len(new) == 1 and new[0] != solution:
            rules = set()
    done = False
    while not done:
        done = True
        for r in rules:
            if len(valid_solutions(num_wires, colors, rules-{r})) == 1:
                rules.remove(r)
                done = False
                break
    #print(rules)
    print(rules, colors, solution)
    return Puzzle(rules, colors, solution)

def puzzle(num_wires: int) -> Puzzle:
    p = basic_puzzle(num_wires)
    rules, colors, solution = p.rules, p.colors, p.solution
    while True:
        done = True
        bad_rule = random_rule(num_wires, colors)
        while len(valid_solutions(num_wires, colors, rules|{bad_rule})) != 0:
            bad_rule = random_rule(num_wires, colors)
        for r in rules:
            if len(valid_solutions(num_wires, colors, (rules-{r})|{bad_rule})) != 0:
                done = False
        if done:
            return Puzzle(rules|{bad_rule}, colors, solution)

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
    print(f"Getting {limit if limit > 0 else "all"} {num_wires} wire puzzles...")
    puzzles = []
    rules = get_all_rules(num_wires)
    all_colorsets = [list(cs) for cs in product(WireColor, repeat=num_wires)]
    shuffle(all_colorsets)
    all_rulesets = [set(rs) for rs in combinations(rules, num_wires)]
    shuffle(all_rulesets)
    for i, rs in enumerate(all_rulesets):
        # if i % 10 == 0:
        #     print(i, "/", len(all_rulesets))
        for j, cs in enumerate(all_colorsets):
            skip = False
            for r in rs:
                if isinstance(r, BeforeColorRule) and cs[r.number] == r.color:
                    skip = True
                    break
            if skip: break
            # print(j, "/", len(all_colorsets))
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
                    if limit > 0 and len(puzzles) > limit:
                        return puzzles
                    break
    return puzzles

if __name__ == "__main__":
    # puzzles = {
    #     3: [puzzle(3).as_dict() for _ in range(100)],
    #     4: [puzzle(4).as_dict() for _ in range(100)],
    #     5: [puzzle(5).as_dict() for _ in range(100)],
    #     6: [puzzle(6).as_dict() for _ in range(100)]
    # }
    puzzles = {
        3: [p.as_dict() for p in get_all_puzzles(3, 100)],
        4: [p.as_dict() for p in get_all_puzzles(4, 100)],
        5: [p.as_dict() for p in get_all_puzzles(5, 100)],
        #6: [p.as_dict() for p in get_all_puzzles(6, 10)], # Runs out of RAM if we do 10 :(
    }
    with Path("../resources/puzzles.json").open("w") as f:
        json.dump(puzzles, f, indent=4)