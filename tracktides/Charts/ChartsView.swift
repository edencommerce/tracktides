import Charts
import SwiftUI

// MARK: - Charts View

struct ChartsView: View {
    @Binding var scrollToSection: ChartSection?

    @State private var viewModel = ChartsViewModel()
    @State private var showingAddShot: Bool = false

    init(scrollToSection: Binding<ChartSection?> = .constant(nil)) {
        _scrollToSection = scrollToSection
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        timeRangePicker

                        LazyVStack(spacing: 24) {
                            weightChart
                            weightChangeChart
                            painChart
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                .onChange(of: scrollToSection) { _, section in
                    if let section {
                        withAnimation {
                            proxy.scrollTo(section, anchor: .top)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            scrollToSection = nil
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Charts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddShot = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                    .accessibilityLabel("Add shot")
                }
            }
            .sheet(isPresented: $showingAddShot) {
                AddShotView()
            }
            .task {
                viewModel.loadSampleData()
            }
        }
    }

    // MARK: - Subviews

    private var timeRangePicker: some View {
        Picker("Time Range", selection: $viewModel.selectedTimeRange) {
            ForEach(ChartTimeRange.allCases) { range in
                Text(range.rawValue).tag(range)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private var weightChart: some View {
        NativeChartCard(
            title: "Weight",
            data: viewModel.weightData,
            allData: viewModel.allWeightData,
            yRange: viewModel.weightRange,
            unit: "lbs",
            color: .purple,
            timeRange: viewModel.selectedTimeRange,
            average: viewModel.weightAverage
        )
        .id(ChartSection.weight)
    }

    private var weightChangeChart: some View {
        NativeChartCard(
            title: "Weight Change",
            data: viewModel.weightChangeData,
            allData: viewModel.allWeightChangeData,
            yRange: viewModel.weightChangeRange,
            unit: "lbs",
            color: .green,
            timeRange: viewModel.selectedTimeRange,
            average: viewModel.weightChangeAverage
        )
        .id(ChartSection.weightChange)
    }

    private var painChart: some View {
        NativeChartCard(
            title: "Injection Pain",
            data: viewModel.painData,
            allData: viewModel.allPainData,
            yRange: 0...10,
            unit: "/10",
            color: .orange,
            timeRange: viewModel.selectedTimeRange,
            average: viewModel.painAverage,
            minYValue: 0
        )
        .id(ChartSection.injectionPain)
    }
}

#Preview {
    ChartsView()
}
